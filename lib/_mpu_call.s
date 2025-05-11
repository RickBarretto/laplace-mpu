/*
 * Function: mpu_call
 * ------------------
 * Triggers the MPU to perform an operation by passing the opcode (in r0) and setting the AWAIT flag to 1.
 *
 * Registers used:
 * - r0: Opcode for the desired operation (input)
 * - r2, r3: Temporary registers
 *
 * Notes:
 * - Sets MPU_AWAIT to 1 before writing the opcode to the MPU control register.
 * - Preserves r3 and lr on the stack.
 *
 * Example:
 *   ``´
 *   mov r0, #OP_ADD      @ Set opcode for addition
 *   bl mpu_call          @ Trigger operation
 *   ```
 *
 *
 * Function: mpu_await
 * -------------------
 * Waits for the MPU to finish its operation by polling the AWAIT flag until it becomes 0.
 *
 * Registers used:
 * - r2, r3: Temporary registers
 *
 * Notes:
 * - Loops until MPU_AWAIT is 0, indicating the operation is complete.
 * - Preserves r3 and lr on the stack.
 *
 * Example:
 *   bl mpu_await         @ Wait for operation to finish
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

