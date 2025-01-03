***************************************
Debugger Storage Overview on ARM(Thumb)
***************************************

Overview of the storage setup on ARM Thumb for the debugger. 
To interact with this storage dump you can either dump the storage location and parse the entries or use the *utils/debugger/debugger_archs/armT_processor_state.py* processor state, which is also passed as an argument in **GA_arm_thumb_debugger**. 

.. note:: All addresses below asume ``STORAGE_LOCATION`` + **Address**


+---------+-----------------+--------------------------------------------------------------------------------+
| Address | Function        | Comment                                                                        |
+=========+=================+================================================================================+
| 0x0     | R0              | Stores Register R0                                                             |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x4     | R1              | Stores Register R1                                                             |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x8     | R2              | Stores Register R2                                                             |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0xc     | R3              | Stores Register R3                                                             |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x10    | R4              | Stores Register R4                                                             |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x14    | R5              | Stores Register R5                                                             |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x18    | R6              | Stores Register R6                                                             |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x1c    | R7              | Stores Register R7                                                             |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x20    | R8              | Stores Register R8 (Indirect Function Call Target ``IFC``)                     |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x24    | R9              | Stores Register R9 (Platform Register ``P``)                                   |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x28    | R10             | Stores Register R10 (Thread Pointer ``TP``)                                    |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x2c    | R11             | Stores Register R11 (Frame Pointer ``FP``)                                     |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x30    | R12             | Stores Register R12 (Intra-Procedure-call-scratched-Register ``IP``)           |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x34    | R13             | Stores Register R13 (Stack Pointer ``SP``)                                     |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x38    | R14             | Stores Register R14 (Link Register ``LR``)                                     |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x3c    | R15             | Stores Register R15 (Program Counter ``PC``)                                   |
+---------+-----------------+--------------------------------------------------------------------------------+
|         |                 |                                                                                |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x7d8   | DBG_MMU_DISABLE | **DISABLED** ``DEBUGGER`` Disable the MMU on entry and enable the MMU on leave |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x7ec   | DBG_JUMP_TO     | ``DEBUGGER`` Address to jump to instead of the debugger                        |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x7f0   | DBG_CONT_EXEC   | ``DEBUGGER`` Do not jump in debugger but into                                  |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x7f4   | TEMP X0         | ``DEBUGGER`` Temporary storage for X0 value                                    |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x7f8   | Store X0        | ``DEBUGGER`` Stores exception id for the ``SMC`` call                          |
+---------+-----------------+--------------------------------------------------------------------------------+
| 0x7fc   | JUMP_ADDR       | ``DEBUGGER`` Memory location that instructs the debugger where to jump to      |
+---------+-----------------+--------------------------------------------------------------------------------+

.. note:: This memory segment is still being updated to add registers

When ``DBG_CONT_EXEC`` is set to **0x77** the debugger will not enter the debugger_main address, but instead restore the original processor state and jump into ``DBG_JUMP_TO``. 
This allows the debugger to be run without user interaction.

.. note::

    By default `register r12 <https://developer.arm.com/documentation/dui0056/d/using-the-procedure-call-standard/register-roles-and-names/register-roles>`_ is corrupted for debugger usage(usually the high registers are not used in thumb mode)

Low/high registers
------------------
ARM in thumb mode has low and high registers. The low registers are R0-R7 and the high registers are R8-R15. 
The high registers can not be directly accessed in thumb mode. The ``LDR`` and ``STR`` can not be used for accessing the high registers.
The ``MOV`` register however can be used to access these registers, which is enough for the debugger to use these registers.

.. code-block:: assembly
    :caption: Accessing high registers in thumb mode and branch to it.

    ldr r2, =addr_debugger_main
    mov r12, r2
    bx r12

    addr_debugger_main:     .word 0x100000

Instructions
============
Some notes on instructions in ``ARM Thumb``.

Branch Exchange
---------------
The ``BX`` instruction is used to branch to a new address and exchange the instruction set if required(ARM/Thumb).
The ``BX`` instruction does **not** set the LR.



