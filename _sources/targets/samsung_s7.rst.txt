==========
Samsung S7
==========
This is an example for a bit more complex target for running gupje.

The Samsung S7 contains a bootROM vulnerability, discovered and exploited by Frederick in `his blog <https://fredericb.info/2020/06/exynos-usbdl-unsigned-code-loader-for-exynos-bootrom.html>`_.

The USB implementation for this target is more complex because it does not expose any *easy* send/receive functions. Instead the DWC3 event handling is processed in the bootROM. 
This means that we need to properly implement the event handling of the DWC3 controller in order to send and receive data, load the next stage and execute it. All in 502 bytes.

USB implementation
------------------
Here is a quick run down of how the USB controller works for this device:

When ``receiving`` data, the usb controller needs to be setup to know what to do when data is received. A callback needs to be setup and the amount of data expected to come in.
After that the transaction will be started, and a loop needs to be run in order to handle all the USB device events. One of the events that should happen at some point is the data receive function. 
The previously setup callback function should then process all the incomming data and raise some sort of signal that it is happy or done in order to stop the USB handling loop. 
So a simple call to receive data will look like this:

.. code-block:: c

    #define recv_buffer 0x206fe00 //0x02021800 + 0x3000
    #define data_received 0x206fd00

    void recv_data_cb(uint32_t endpoint, uint32_t len){
        char *dest_buf = (char *)recv_buffer;
        volatile void *dref = (void *)data_received;
        
        void *rbuf = get_endpoint_recv_buffer(endpoint);
        for(int i= 0; i < len; i++){
            dest_buf[i] = *(char *)(void *)((int)rbuf + i);
        }
        *(uint8_t *)dref = 1; // Mark as ready
    }

    void recv_data(uint32_t address, uint32_t size){
        // 
        volatile void *dref = (void *)data_received;
        *(uint8_t *)dref = 0;

        maybe_usb_setup_read(2, recv_data_cb, 0x200);
        uint32_t rbuf = get_endpoint_recv_buffer(2);
        dwc3_ep0_start_trans(2, rbuf, 0x200);
        while(1){
            usb_event_handler();
            volatile val = *(volatile uint8_t *)dref;
            if(val == 1){
                break;
            }
        }
        // Copy to destination location
        char *dest_buf = (char *)address;
        for(int i= 0; i < size; i++){
            dest_buf[i] = *(char *)(void *)((int)recv_buffer + i);
        }
    }

For ``sending`` the data the setup is somewhat the same. The data needs to be sent to the USB controller and a callback needs to be setup to know when the data has been sent.

.. code-block:: c

    void send_data_cb(uint32_t endpoint, uint32_t len){
        // Tell event handler that the data was received
        volatile void *dref = (void *)data_received;
        *(uint8_t *)dref = 1; // Mark as ready
    }

    void send(void *address, uint32_t size, uint32_t *error){
        volatile void *dref = (void *)data_received;
        *(uint8_t *)dref = 0;
        maybe_usb_setup_read(0x1, send_data_cb, size);
        // uint32_t rbuf = get_endpoint_recv_buffer(1);
        dwc3_ep0_start_trans(1, (uint64_t)address, size);
        while(1){
            usb_event_handler();
            if(*(uint8_t *)dref == 1){
                break;
            }
            // exynos_sleep(1, 1000);
        }
    }

Stage 1
-------
Due to size constraints the first stage is a simple loader that will load the second stage from the host. The second stage being the actual debugger.

