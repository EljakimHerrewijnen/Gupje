start:
    LDR X15, addr_debugger_storage

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

    STR X30, [X15, #240]

    MOV X0, SP
    STR X0, [X15, #248]

    # Store NZCV flags
    MRS X0, NZCV
    STR X0, [X15, #0x1c8]

    // Does not override the SP etc. TODO ELHER make configurable in debugger (during setup)
    // B debugger_main

    // Overwrite SP and FP with the debugger stack location
    LDR X0, addr_debugger_stack
    MOV SP, X0
    MOV FP, X0

    // Dump special registers
    BL dump_special_regs

    // See if we need to disable the MMU on entry
    // LDR X0, [X15, #0xfd0]
    // CMP X0, #0x777 //Disable the MMU
    // BL disable_mmu

    // Compare to see if we need to jump into the debugger or need to continue the 'normal' execution flow
    LDR X0, [X15, #4064]
    CMP X0, #0x777
    B.NE debugger_main


    # Continue 'normal' execution flow
    BL sync_processor_state

    // Restore LR and FP
    LDR X30, [X15, #240]
    LDR X29, [X15, #232]

    // Restore the stack pointer
    LDR X0, [X15, #248]
    MOV SP, X0

    // Also restore X0
    LDR X0, [X15, #0]

    LDR X15, [X15, #0xfd8]
    BR X15

.text
.global disable_mmu
disable_mmu:
    MRS X0, SCTLR_EL3
    AND X0, X0, #-0x2
    RET

.text
.global enable_mmu
enable_mmu:
    // TODO crashes on EL1?
    MRS X0, SCTLR_EL3
    ORR X0, X0, #0x1
    RET

.text
.global restore_and_jump
restore_and_jump:
    BL sync_processor_state

    //See if we need to enable the MMU
    // LDR X0, [X15, #0xfd0]
    // CMP X0, #0x777 //Disable the MMU
    // BL enable_mmu

    // Restore LR and FP
    LDR X30, [X15, #240]
    LDR X29, [X15, #232]

    // Restore the stack pointer
    LDR X0, [X15, #248]
    MOV SP, X0

    // Restore NZCV flags
    LDR X0, [X15, #0x1c8]
    MSR NZCV, X0

    // Also restore X0
    LDR X0, [X15, #0]

    // Load target address and branch to it without setting the LR
    // JUMP_ADDR
    LDR X15, [X15, #4088]
    BR X15

.text
.global dump_special_el3
dump_special_el3:
    MRS X0, TTBR0_EL3
    STR X0, [X15, #256]

    MRS X0, SCTLR_EL3
    STR X0, [X15, #280]

    MRS X0, VBAR_EL3
    STR X0, [X15, #304]

    MRS X0, TCR_EL3
    STR X0, [X15, #328]

    MRS X0, ELR_EL3
    STR X0, [X15, #352]

    MRS X0, SPSR_EL3
    STR X0, [X15, #400]

    MRS X0, MAIR_EL3
    STR X0, [X15, #424]

    MRS X0, SP_EL2
    STR X0, [X15, #376]

    // Also dump el2, which will also dump el1
    B dump_special_el2

.text
.global dump_special_el2
dump_special_el2:
    MRS X0, TTBR0_EL2
    STR X0, [X15, #264]

    MRS X0, SCTLR_EL2
    STR X0, [X15, #288]

    MRS X0, VBAR_EL2
    STR X0, [X15, #312]

    MRS X0, TCR_EL2
    STR X0, [X15, #336]

    MRS X0, ELR_EL2
    STR X0, [X15, #360]

    MRS X0, SPSR_EL2
    STR X0, [X15, #408]

    MRS X0, MAIR_EL2
    STR X0, [X15, #432]

    MRS X0, VTCR_EL2
    STR X0, [X15, #0x1e0]

    MRS X0, HCR_EL2
    STR X0, [X15, #0x1f0]

    // see https://community.arm.com/support-forums/f/architectures-and-processors-forum/49184/difference-between-sp_el1-and-spsel-mov
    MRS X0, SP_EL1
    STR X0, [X15, #384]

    // also dump EL1
    B dump_special_el1

.text
.global dump_special_el1
dump_special_el1:
    // EL1 registers dump
    MRS X0, TTBR0_EL1
    STR X0, [X15, #272]

    MRS X0, SCTLR_EL1
    STR X0, [X15, #296]

    MRS X0, VBAR_EL1
    STR X0, [X15, #320]

    MRS X0, TCR_EL1
    STR X0, [X15, #344]

    MRS X0, ELR_EL1
    STR X0, [X15, #368]

    MRS X0, SPSR_EL1
    STR X0, [X15, #416]

    MRS X0, MAIR_EL1
    STR X0, [X15, #440]

    // EL0 registers
    MRS X0, SP_EL0
    STR X0, [X15, #392]

    RET

.text
.global dump_special_regs
dump_special_regs:
    LDR X15, addr_debugger_storage

    MRS X0, CurrentEL
    STR X0, [X15, #448]

    cmp X0, #0b1100 // EL3
    BEQ dump_special_el3

    cmp X0, #0b1000 // EL2
    BEQ dump_special_el2
    

    cmp X0, #0b0100 // EL1
    BEQ dump_special_el1

    RET

.text
.global write_special_el3
write_special_el3:
    LDR X0, [X15, #256]
    MSR  TTBR0_EL3, X0

    LDR X0, [X15, #280]
    MSR SCTLR_EL3, X0

    LDR X0, [X15, #304]
    MSR VBAR_EL3, X0

    LDR X0, [X15, #328]
    MSR TCR_EL3, X0

    LDR X0, [X15, #352]
    MSR ELR_EL3, X0

    LDR X0, [X15, #376]
    MSR SP_EL2, X0

    LDR X0, [X15, #400]
    MSR SPSR_EL3, X0

    LDR X0, [X15, #424]
    MSR MAIR_EL3, X0

    BL write_special_el2
    BL write_special_el1

    RET

.text
.global write_special_el2
write_special_el2:
    LDR X0, [X15, #264]
    MSR TTBR0_EL2, X0

    LDR X0, [X15, #288]
    MSR SCTLR_EL2, X0

    LDR X0, [X15, #312]
    MSR VBAR_EL2, X0

    LDR X0, [X15, #336]
    MSR TCR_EL2, X0

    LDR X0, [X15, #360]
    MSR ELR_EL2, X0

    LDR X0, [X15, #384]
    MSR SP_EL1, X0

    LDR X0, [X15, #408]
    MSR SPSR_EL2, X0

    LDR X0, [X15, #432]
    MSR MAIR_EL2, X0

    LDR X0, [X15, #0x1e0]
    MSR VTCR_EL2, X0

    BL write_special_el1

    RET

.text
.global write_special_el1
write_special_el1:
    LDR X0, [X15, #272]
    MSR TTBR0_EL1, X0

    LDR X0, [X15, #296]
    MSR SCTLR_EL1, X0

    LDR X0, [X15, #320]
    MSR VBAR_EL1, X0

    LDR X0, [X15, #344]
    MSR TCR_EL1, X0

    LDR X0, [X15, #368]
    MSR ELR_EL1, X0

    LDR X0, [X15, #392]
    MSR SP_EL0, X0

    LDR X0, [X15, #416]
    MSR SPSR_EL1, X0

    LDR X0, [X15, #440]
    MSR MAIR_EL1, X0
    RET

.text
.global write_special_regs
write_special_regs:
    LDR X15, addr_debugger_storage

    MRS X0, CurrentEL
    STR X0, [X15, #448]

    cmp X0, #0b1100 // EL3
    BEQ write_special_el3

    cmp X0, #0b1000 // EL2
    BEQ write_special_el2

    cmp X0, #0b0100 // EL1
    BEQ write_special_el1

    RET


.text
.global debugger_sync_special_regs
debugger_sync_special_regs:
    BL write_special_regs
    B debugger_main

.text
.global debugger_dump_special_regs
debugger_dump_special_regs:
    BL dump_special_regs
    B debugger_main

.text
.global sync_processor_state
sync_processor_state:
    //Corrupt X15 to use it to restore the rest of the state, except for the SP, LR and FP
    LDR X15, addr_debugger_storage

    LDR X1, [X15, #8]
    LDR X2, [X15, #16]
    LDR X3, [X15, #24]
    LDR X4, [X15, #32]
    LDR X5, [X15, #40]
    LDR X6, [X15, #48]
    LDR X7, [X15, #56]
    LDR X8, [X15, #64]
    LDR X9, [X15, #72]
    LDR X10, [X15, #80]
    LDR X11, [X15, #88]
    LDR X12, [X15, #96]
    LDR X13, [X15, #104]
    LDR X14, [X15, #112]
    LDR X15, [X15, #120]
    LDR X16, [X15, #128]
    LDR X17, [X15, #136]
    LDR X18, [X15, #144]
    LDR X19, [X15, #152]
    LDR X20, [X15, #160]
    LDR X21, [X15, #168]
    LDR X22, [X15, #176]
    LDR X23, [X15, #184]
    LDR X24, [X15, #192]
    LDR X25, [X15, #200]
    LDR X26, [X15, #208]
    LDR X27, [X15, #216]
    LDR X28, [X15, #224]
    RET

.text
.global restore_and_return
restore_and_return:
    B sync_processor_state

    // Restore LR and FP
    LDR X30, [X15, #240]
    LDR X29, [X15, #232]

    // Restore the stack pointer
    LDR X0, [X15, #248]
    MOV SP, X0

    // Restore NZCV flags
    LDR X0, [X15, #0x1c8]
    MSR NZCV, X0

    // Also restore X0
    LDR X0, [X15, #0]

    RET

.text
.global sync_debugger
sync_debugger:
    BL sync_processor_state
    B debugger_main

.align 3


addr_debugger_storage:  .quad debugger_storage
addr_debugger_stack:    .quad debugger_stack
