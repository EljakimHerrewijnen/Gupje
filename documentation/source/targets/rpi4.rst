==============
Raspberry Pi 4
==============

The Raspberry Pi 4 is a single-board computer developed by the ``Raspberry Pi Foundation``. It is freely available and requires no exploit to run code on it. 
On top of that it is well supported in ``Qemu``, making this the cheapest and easiest target for gupje.

Code
----
The github code for this `is here <https://github.com/EljakimHerrewijnen/rpi4_gupje>`_.

.. hint::

    The code that runs on the Raspberry Pi4 is based on `this awesome repository  <https://github.com/ethanfaust/rpi4-baremetal-uart>`_.

Clone this repository *somewhere* and link the cloned folder in the ``devices/`` folder of gupje.

.. code-block:: bash

    git clone --recursive https://github.com/EljakimHerrewijnen/rpi4_gupje
    cd /path/to/gupje/devices
    ln -s /path/to/rpi4_gupje rpi4

You can now build the target by running the following command from gupje's root directory directory:

.. code-block:: bash

    cd /path/to/gupje
    make -f devices/rpi4/Makefile

In ``bin/rpi4/`` you will find the ``debugger.bin`` file, which will be used by the ``qemu.py`` script.

Running Qemu
############
From ``devices/rpi4`` navigate to ``rpi4-baremetal-uart/`` folder and run make with a cross compiler.

.. code-block:: bash

    cd /path/to/gupje/devices/rpi4/rpi4-baremetal-uart
    ARCH=arm64 PREFIX=aarch64-linux-gnu- make


Implementation
==============
Only send and receive need to be implemented for this target. For this target UART is used. 

The debugger expects send/recv to be handled by the user so we need to build some logic to know that the data has been send and that the amount of expected data has been received. The following C code implements the send/recv for UART. 

.. code-block:: c

    void recv_data(void *address, uint32_t size){
        for(int i=0; i < size; i++){
            *((char *)address + i) = uart_get();
        }
    }

    void send(void *address, uint64_t size, uint32_t *error){
        for(int i=0; i < size; i++){
            uart_send(*((char *)address + i));
        }
    }

However, in this implementation the debugger will need to link the uart_get and uart_send functions. In order to do that we copy the functions from the elf file and add them to the symbols.txt file.

.. code-block:: bash

    $ readelf -a kernel8.elf | grep uart_
    25: 00000000000803a8    36 FUNC    GLOBAL DEFAULT    1 uart_get
    27: 0000000000080384    36 FUNC    GLOBAL DEFAULT    1 uart_send
    34: 0000000000080400    88 FUNC    GLOBAL DEFAULT    1 uart_puts
    35: 000000000008024c   312 FUNC    GLOBAL DEFAULT    1 uart_init
    36: 0000000000080458    84 FUNC    GLOBAL DEFAULT    1 uart_hex
    39: 00000000000803cc    52 FUNC    GLOBAL DEFAULT    1 uart_getc

Add the symbols uart_get and uart_send to the symbols.txt file, along with the debugger regions:

.. code-block:: text

    debugger_storage = 0x85000;
    debugger_stack = 0x83000;
    debugger_entry = 0x81000;
    uart_get = 0x00000000000803a8;
    uart_send = 0x0000000000080384;

See the makefile for details on how the linking is done.

