/*
 * Function: mpu_multiply
 * --------------------
 * Triggers the FPGA to perform a matrix multiplication operation.
 *
 * Registers used:
 * - r0: Temporary register
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