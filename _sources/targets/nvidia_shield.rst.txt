====================
Nvidia Shield Tablet
====================
Exploitation for this target was done by `LordRafa <https://github.com/LordRafa>`_

The nvidia shield tablet, both st8 and k1 versions, have a Tegra K1 processor. This processor is based on the ARM Cortex A15 architecture. 

This processor has the same bootROM bug as the Nintendo Switch, allowing us to run code very early on in the processor. 

Code
----
The github code for this `is here <https://github.com/EljakimHerrewijnen/nvidia_shield>`_.

Debugger implementation
-----------------------
The bootROM has 2 endpoint functions to read/write data over USB, which we can repurpose to send and receive data from the debugger.

.. code-block:: c

    #define BOOTROM_EP1_IN_WRITE_IMM    0x001065C0
    #define BOOTROM_EP1_OUT_READ_IMM    0x00106612

    typedef void (*ep1_x_imm_t)(void *buffer, uint32_t size, uint32_t *num_xfer);
    ep1_x_imm_t usb_recv = (ep1_x_imm_t) ( BOOTROM_EP1_OUT_READ_IMM | 1 );
    ep1_x_imm_t usb_send = (ep1_x_imm_t) ( BOOTROM_EP1_IN_WRITE_IMM | 1 );

    void send(void *buffer, uint32_t size, uint32_t *num_xfer){
        usb_send(buffer, size, num_xfer);
    }

    int recv(void *buffer, uint32_t size, uint32_t *num_xfer){
        usb_recv(buffer, size, num_xfer);
        return (int)&num_xfer;
    }


