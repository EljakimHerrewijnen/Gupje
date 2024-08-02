start:
    // TODO there is an ARM instruction that pushes all values to the stack
    // LDR R15, addr_debugger_storage
    STR R0, [R15, #0]
    STR R1, [R15, #4]
    STR R2, [R15, #8]
    STR R3, [R15, #12]
    STR R4, [R15, #16]
    STR R5, [R15, #20]
    STR R6, [R15, #24]
    STR R7, [R15, #28]
    STR R8, [R15, #64]
    STR R9, [R15, #72]
    STR R10, [R15, #80]
    STR R11, [R15, #88]
    STR R12, [R15, #96]
    STR R13, [R15, #104]
    STR R14, [R15, #112]
    MOV R0, SP
    STR R0, [R15, #248]

    // Overwrite SP and FP with the debugger stack location
    // LDR R0, addr_debugger_stack
    MOV SP, R0
    MOV FP, R0
    
    B debugger_main

.text
.global restore_and_jump
restore_and_jump:
    BL sync_processor_state

    // Restore the stack pointer
    LDR R0, [R15, #248]
    MOV SP, R0

    // Also restore R0
    LDR R0, [R15, #0]

    // Load target address and branch to it
    LDR R15, [R15, #4088]
    B debugger_main

.text
.global dump_special_regs
dump_special_regs:    
    B debugger_main

.text
.global write_special_regs
write_special_regs:
    B debugger_main


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
    //Corrupt R15 to use it to restore the rest of the state, eRcept for the SP, LR and FP
    // R13 == SP, R14 == LR, R15 == PC (oops)
    // LDR R15, addr_debugger_storage
    
    LDR R1, [R15, #8]
    LDR R2, [R15, #16]
    LDR R3, [R15, #24]
    LDR R4, [R15, #32]
    LDR R5, [R15, #40]
    LDR R6, [R15, #48]
    LDR R7, [R15, #56]
    LDR R8, [R15, #64]
    LDR R9, [R15, #72]
    LDR R10, [R15, #80]
    LDR R11, [R15, #88]
    LDR R12, [R15, #96]
    LDR R13, [R15, #104]
    LDR R14, [R15, #112]
    bx lr

.text
.global restore_and_return
restore_and_return:
    B sync_processor_state

    // Restore the stack pointer
    LDR R0, [R15, #248]
    MOV SP, R0

    // Also restore R0
    LDR R0, [R15, #0]

    BX LR

.text
.global sync_debugger
sync_debugger:
    BL sync_processor_state
    B debugger_main

.align 3

