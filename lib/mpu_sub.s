/*
 * Function: mpu_sub
 * --------------------
 * Triggers the FPGA to perform a matrix subtraction operation by passing opcode 1.
 *
 * Registers used:
 * - r0: Temporary register for opcode
 *
 * Notes:
 * - This function writes the opcode 1 to the MPU control register to trigger subtraction.
 * - The function preserves r0 and lr on the stack.
 *
 * Example:
 *   Set up the registers before calling:
 *   ```
 *   bl mpu_sub
 *   ```
 */

#include "_mpu_constants.s"

.global mpu_sub
.type mpu_sub, %function

mpu_sub:
    push {r0, lr}

    @ Call subtract operation
    mov r0, #OP_SUB
    bl _mpu_call

    @ Finish
    pop {r0, lr}
    bx lr                   @ Return from function
