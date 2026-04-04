.align 1
.thumb
start:
    @ Store R0 to the stack
    push {r0}

    LDR R0, addr_debugger_storage
    stmia r0, {r0-r7}

    @ Also store r0 by using r1
    ldr r1, addr_debugger_storage
    pop {r0}
    str r0, [r1, #0]
    # Keep using r0
    LDR R0, addr_debugger_storage

    @ Store R8 to R15, not available directly in thumb mode
    mov r1, r8
    str r1, [r0, #0x20]
    mov r1, r9
    str r1, [r0, #0x24]
    mov r1, r10
    str r1, [r0, #0x28]
    mov r1, r11
    str r1, [r0, #0x2c]
    mov r1, r12 //ip scratch 
    str r1, [r0, #0x30]
    mov r1, sp //sp
    str r1, [r0, #0x34]
    mov r1, lr //lr
    str r1, [r0, #0x38]
    mov r1, pc //pc
    str r1, [r0, #0x3c]

    // set debugger stack (r13 sp, r14 lr, r15 pc)
    ldr r0, addr_debugger_stack
    mov sp, r0

    // Compare to see if we need to jump into the debugger or need to continue the 'normal' execution flow
    // Default is jump in debugger
    // CNT_EXEC 0x7f0
    ldr r1, addr_debugger_storage
    ldr r0, =0x700
    add r0, #0xf0
    add r0, r0, r1

    CMP r0, #0x77
    beq start_normal

    @ TODO, use r8, how can I clear it
    ldr r2, addr_debugger_main
    mov r12, r2
    bx r12

    // Continue 'normal' execution flow
start_normal:
    BL sync_processor_state

    // Restore LR, TODO
    @ LDR LR, [r1, #240]

    @ // Restore the stack pointer
    @ LDR R0, [r1, #248]
    @ MOV SP, R0

    // Also restore X0
    LDR R0, [r1, #0]
    
    // 0x7ec DBG_JUMP_TO
    @ LDR r1, [r1, #0x7ec] 
    @ bx r1


.text
.global restore_and_jump
restore_and_jump:
    // Restores all registers except for LR and SP
    BL sync_processor_state

    // restore SP, LR
    ldr r0, addr_debugger_storage
    ldr r1, [r0, #0x34]
    mov sp, r1 //SP
    ldr r1, [r0, #0x38]
    mov lr, r1 //LR

    @ Load JUMP_ADDR 0x7fc into r12
    ldr r0, addr_debugger_storage
    ldr r1, =0x7fc
    add r1, r1, r0
    ldr r1, [r1] @ JUMP_ADDR
    mov r12, r1

    // Restore r0 and r1
    ldr r0, addr_debugger_storage
    ldr r1, [r0, #4]
    ldr r0, [r0]    

    @ At this point everything is restored except for r12, which contains the jump address
    bx r12

.text
.global debugger_sync_special_regs
debugger_sync_special_regs:
    @ mov r4, #0x77
    // TODO, what special regs??
    bx LR

.text
.global dump_special_regs
dump_special_regs:
    // TODO, what special regs??
    bx LR


.text
.global debugger_dump_special_regs
debugger_dump_special_regs:
    BL dump_special_regs
    B debugger_main


.text 
.global sync_processor_state
sync_processor_state:
    @ Syncs general purpose registers back to the cpu and branches to the LR

    @ Load r8-r12
    ldr r0, addr_debugger_storage
    ldr r1, [r0, #0x20]
    mov r8, r1
    ldr r1, [r0, #0x24]
    mov r9, r1
    ldr r1, [r0, #0x28]
    mov r10, r1
    ldr r1, [r0, #0x2c]
    mov r11, r1
    ldr r1, [r0, #0x30]
    mov r12, r1
    
    @ Not restoring SP, LR and PC. Left here as reference
    @ ldr r1, [r0, #0x34]
    @ mov r13, r1 //sp
    @ ldr r1, [r0, #0x38]
    @ mov r14, r1 //lr
    @ ldr r1, [r0, #0x3c]
    @ mov r15, r1 //pc

    @ load r0-r7
    ldr r0, addr_debugger_storage
    ldmia r0, {r0-r7}

    bx lr


.text
.global restore_and_return
restore_and_return:
    B sync_processor_state

    // restore SP, LR
    ldr r0, addr_debugger_storage
    ldr r1, [r0, #0x30]
    mov r12, r1 //IP
    ldr r1, [r0, #0x34]
    mov sp, r1 //SP
    ldr r1, [r0, #0x38]
    mov lr, r1 //LR

    // Restore r0 and r1
    @ ldr r0, addr_debugger_storage
    ldr r1, [r0, #4]
    ldr r0, [r0]    

    @ At this point everything is restored including the LR. Return to it
    BX LR

.text
.global sync_debugger
sync_debugger:
    BL sync_processor_state
    b debugger_main

.align 4
addr_debugger_storage:  .word debugger_storage
addr_debugger_stack:    .word debugger_stack
addr_debugger_main:     .word debugger_main