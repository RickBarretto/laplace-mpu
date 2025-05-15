/*
 * Function: mpu_call
 * ------------------
 * Triggers the MPU to perform an operation by passing the opcode (in r0) and setting the AWAIT flag to 1.
 * Then, it waits for the MPU to clear the AWAIT flag, indicating the operation is complete.
 *
 * Registers used:
 * - r0: Opcode for the desired operation (input)
 * - r2, r3: Temporary registers
 *
 * Notes:
 * - Sets MPU_AWAIT to 1 before writing the opcode to the MPU control register.
 * - Waits in a loop until the MPU clears the AWAIT flag (returns the flag to 0).
 * - Preserves r3 and lr on the stack.
 *
 * Example:
 *   ``´
 *   mov r0, _mpu_      @ Set opcode for addition
 *   mov r0, #OP_ADD      @ Set opcode for addition
 *   bl mpu_call          @ Trigger operation and wait for completion
 *   ```
 */

#include "_mpu_constants.s"

.global mpu_call
.type mpu_call, %function


_mpu_call:
    push {r3, lr}
    
    @ Store Opcode




    ldr r3, =MPU_OPCODE
    str r0, [r3]           @ Write opcode

    @ Store Await
    ldr r3, =MPU_AWAIT
    mov r2, #1
    str r2, [r3]           @ Set AWAIT to 1

await_loop:
    @ Load Await
    ldr r3, =MPU_AWAIT
    ldr r2, [r3]
    
    @ Wait for MPU finish its task
    cmp r2, #0
    bne await_loop    
    
    @ Finish
    pop {r3, lr}
    bx lr

