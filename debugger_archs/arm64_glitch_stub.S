.text
.global glitch_registers_loop
glitch_registers_loop:
    BL trigger_high
    BL trigger_low
    BL glitch_dump_registers
    RET

.text
.global glitch_out_loop
glitch_out_loop:
    BL trigger_high
    MOV X0, #0x1
    glitch_loop:
    MOV X1, #0x0
    CMP X1, X0
    b.ne glitch_loop
    BL trigger_low
    B debugger_main

.text
.global glitch_dump_registers
glitch_dump_registers:
    LDR X15, glitch_storage
    STP        X0, X1, [X15, #0x0]
    STP        X2, X3, [X15, #0x10]
    STP        X4, X5, [X15, #0x20]
    STP        X6, X7, [X15, #0x30]
    STP        X8, X9, [X15, #0x40]
    STP        X10, X11, [X15, #0x50]
    STP        X12, X13, [X15, #0x60]
    STP        X14, X15, [X15, #0x70]
    STP        X16, X17, [X15, #0x80]
    STP        X18, X19, [X15, #0x90]
    STP        X20, X21, [X15, #0xa0]
    STP        X22, X23, [X15, #0xb0]
    STP        X24, X25, [X15, #0xc0]
    STP        X26, X27, [X15, #0xd0]
    STP        X28, X29, [X15, #0xe0]
    STP        X30, X31, [X15, #0xf0]
    RET

glitch_storage:  .quad glitch_storage