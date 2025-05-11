/*
 * Function: mpu_determinant
 * ------------------------
 * Triggers the MPU to perform a matrix determinant operation for a given size (1-5).
 * Returns 0 on success, 1 if size is out of range.
 *
 * Registers used:
 * - r0: Matrix size (input), also used for return value (0=success, 1=error)
 * - r3: Temporary register
 *
 * Example:
 *   mov r0, #3             @ Matrix size 3x3
 *   bl mpu_determinant     @ Call function
 *   cmp r0, #0             @ Check for success
 */

#include "_mpu_constants.s"
#include "_mpu_op.s"

.global mpu_determinant
.type mpu_determinant, %function

mpu_determinant:
    push {r3, lr}

    @ Check if size is in range 1-5
    cmp r0, #1
    blt .error
    cmp r0, #5
    bgt .error

    @ Store size
    ldr r3, =MPU_SIZE
    str r0, [r3]

    @ Call determinant operation
    mov r0, #OP_DET
    bl _mpu_call

    mov r0, #0             @ Success
    pop {r3, lr}
    bx lr

.error:
    mov r0, #1             @ Error code for out-of-range
    pop {r3, lr}
    bx lr
