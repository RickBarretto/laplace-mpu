/*
 * Function: mpu_transpose
 * --------------------
 * Triggers the FPGA to perform a matrix transpose operation.
 *
 * Registers used:
 * - r0: Temporary register for opcode
 *
 * Example:
 *   Call the function directly:
 *   ```
 *   bl mpu_transpose
 *   ```
 */

#include "_mpu_constants.s"
#include "_mpu_op.s"

.global mpu_transpose
.type mpu_transpose, %function

mpu_transpose:
    push {r0, lr}

    @ Call transpose operation
    mov r0, #OP_TRS
    bl _mpu_call

    @ Finish
    pop {r0, lr}
    bx lr
