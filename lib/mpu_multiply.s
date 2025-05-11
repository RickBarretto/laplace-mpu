/*
 * Function: mpu_multiply
 * --------------------
 * Triggers the FPGA to perform a matrix multiplication operation by passing the opcode.
 *
 * Registers used:
 * - r0: Temporary register
 *
 * Notes:
 * - This function writes the opcode for matrix multiplication to the control register (MPU_OPCODE).
 * - The function preserves r0 and lr on the stack.
 *
 * Example:
 *   Call the function:
 *   ```
 *   bl mpu_multiply
 *   ```
 */

#include "_mpu_constants.s"

.global mpu_multiply
.type mpu_multiply, %function

mpu_multiply:
    push {r0, lr}

    @ Call multiply operation
    mov r0, #OP_MUL
    bl _mpu_call

    @ Finish
    pop {r0, lr}
    bx lr