/*
 * Function: mpu_add
 * --------------------
 * Triggers the FPGA to perform a matrix addition operation by passing opcode 1.
 *
 * Registers used:
 * - r0: Temporary register for opcode
 *
 * Notes:
 * - This function writes the opcode 1 to the FPGA control register to trigger addition.
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
