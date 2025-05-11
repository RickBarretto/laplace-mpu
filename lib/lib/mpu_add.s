/*
 * Function: mpu_add
 * --------------------
 * Triggers the FPGA to perform a matrix addition operation.
 *
 * Registers used:
 * - r0: Temporary register for opcode
 *
 * Example:
 *   Call the function directly:
 *   ```
 *   bl mpu_add
 *   ```
 */

#include "_mpu_constants.s"
#include "_mpu_op.s"

.global mpu_add
.type mpu_add, %function

mpu_add:
    push {r0, lr}

    @ Call add operation
    mov r0, #OP_ADD
    bl _mpu_call

    @ Finish
    pop {r0, lr}
    bx lr
