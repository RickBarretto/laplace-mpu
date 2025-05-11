/*
 * Function: mpu_sub
 * --------------------
 * Triggers the FPGA to perform a matrix subtraction operation.
 *
 * Registers used:
 * - r0: Temporary register for opcode
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
