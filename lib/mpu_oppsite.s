/*
 * Function: mpu_oppsite
 * -----------------------
 * Triggers the FPGA to perform an opposite (negation) matrix operation.
 *
 * Registers used:
 * - r0: Temporary register for opcode
 *
 * Example:
 *   Call the function directly:
 *   ```
 *   bl mpu_oppsite
 *   ```
 */

#include "_mpu_constants.s"

.global mpu_oppsite
.type mpu_oppsite, %function

mpu_oppsite:
    push {r0, lr}

    @ Call opposite operation
    mov r0, #OP_OPP
    bl _mpu_call

    @ Finish
    pop {r0, lr}
    bx lr