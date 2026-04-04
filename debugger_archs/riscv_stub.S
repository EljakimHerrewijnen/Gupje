.section .text
.global start
start:
    la t0, debugger_storage

    sw x0, 0(t0)
    sw x1, 4(t0)
    sw x2, 8(t0)
    sw x3, 12(t0)
    sw x4, 16(t0)
    sw x5, 20(t0)
    sw x6, 24(t0)
    sw x7, 28(t0)
    sw x8, 32(t0)
    sw x9, 36(t0)
    sw x10, 40(t0)
    sw x11, 44(t0)
    sw x12, 48(t0)
    sw x13, 52(t0)
    sw x14, 56(t0)
    sw x15, 60(t0)
    sw x16, 64(t0)
    sw x17, 68(t0)
    sw x18, 72(t0)
    sw x19, 76(t0)
    sw x20, 80(t0)
    sw x21, 84(t0)
    sw x22, 88(t0)
    sw x23, 92(t0)
    sw x24, 96(t0)
    sw x25, 100(t0)
    sw x26, 104(t0)
    sw x27, 108(t0)
    sw x28, 112(t0)
    sw x29, 116(t0)
    sw x30, 120(t0)
    sw x31, 124(t0)

    csrr t1, mstatus
    sw t1, 0x100(t0)
    csrr t1, mepc
    sw t1, 0x104(t0)
    csrr t1, mtvec
    sw t1, 0x108(t0)
    csrr t1, mcause
    sw t1, 0x10c(t0)
    csrr t1, mtval
    sw t1, 0x110(t0)
    csrr t1, mie
    sw t1, 0x114(t0)
    csrr t1, mip
    sw t1, 0x118(t0)

    la sp, debugger_stack
    j debugger_main

.text
.global dump_special_regs
dump_special_regs:
    la t0, debugger_storage

    csrr t1, mstatus
    sw t1, 0x100(t0)
    csrr t1, mepc
    sw t1, 0x104(t0)
    csrr t1, mtvec
    sw t1, 0x108(t0)
    csrr t1, mcause
    sw t1, 0x10c(t0)
    csrr t1, mtval
    sw t1, 0x110(t0)
    csrr t1, mie
    sw t1, 0x114(t0)
    csrr t1, mip
    sw t1, 0x118(t0)

    ret

.text
.global write_special_regs
write_special_regs:
    la t0, debugger_storage

    lw t1, 0x100(t0)
    csrw mstatus, t1
    lw t1, 0x104(t0)
    csrw mepc, t1
    lw t1, 0x108(t0)
    csrw mtvec, t1
    lw t1, 0x114(t0)
    csrw mie, t1

    ret

.text
.global debugger_sync_special_regs
debugger_sync_special_regs:
    call write_special_regs
    j debugger_main

.text
.global debugger_dump_special_regs
debugger_dump_special_regs:
    call dump_special_regs
    j debugger_main

.text
.global sync_processor_state
sync_processor_state:
    la t6, debugger_storage

    lw x3, 12(t6)
    lw x4, 16(t6)
    lw x5, 20(t6)
    lw x6, 24(t6)
    lw x7, 28(t6)
    lw x8, 32(t6)
    lw x9, 36(t6)
    lw x10, 40(t6)
    lw x11, 44(t6)
    lw x12, 48(t6)
    lw x13, 52(t6)
    lw x14, 56(t6)
    lw x15, 60(t6)
    lw x16, 64(t6)
    lw x17, 68(t6)
    lw x18, 72(t6)
    lw x19, 76(t6)
    lw x20, 80(t6)
    lw x21, 84(t6)
    lw x22, 88(t6)
    lw x23, 92(t6)
    lw x24, 96(t6)
    lw x25, 100(t6)
    lw x26, 104(t6)
    lw x27, 108(t6)
    lw x28, 112(t6)
    lw x29, 116(t6)
    lw x30, 120(t6)
    lw x31, 124(t6)

    ret

.text
.global restore_and_jump
restore_and_jump:
    call sync_processor_state

    la t6, debugger_storage
    lw x2, 8(t6)
    lw x1, 4(t6)
    lw t0, 0x7fc(t6)
    jr t0

.text
.global restore_and_return
restore_and_return:
    call sync_processor_state

    la t6, debugger_storage
    lw x2, 8(t6)
    lw x1, 4(t6)
    ret

.text
.global sync_debugger
sync_debugger:
    call sync_processor_state
    j debugger_main
