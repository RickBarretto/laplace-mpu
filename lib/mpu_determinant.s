/*
 * Function: mpu_determinant
 * ------------------------
 * Triggers the MPU to perform a matrix determinant operation for a given size (1-5).
 * Returns 0 on success, 1 if size is out of range.
 *
 * Uses the mapped MPU base address for register access.
 *
 * Registers used:
 * - r0: Holds mapped base address (must be set by caller)
 * - r1: Matrix size (input), also used for return value (0=success, 1=error)
 * - r3: Temporary register
 *
 * Example:
 *   bl mpu_map_base_address   @ Get mapped base address in r0
 *   mov r1, #3                @ Matrix size 3x3
 *   bl mpu_determinant        @ Call function
 *   cmp r0, #0                @ Check for success
 *
 * Note: Assumes r1 contains the mapped base address.
 */

#include "_mpu_constants.s"
#include "_mpu_op.s"

.global mpu_determinant
.type mpu_determinant, %function

mpu_determinant:
    push {r3, lr}

    @ Check if size is in range 1-5
    cmp r1, #1
    blt .error
    cmp r1, #5
    bgt .error

    @ Store size using mapped base address in r1
    ldr r3, =MPU_SIZE
    add r3, r0, r3           @ r3 = mapped_base + offset
    str r1, [r3]

    mov r0, #OP_DET
    bl _mpu_call

    mov r0, #0             @ Success
    pop {r3, lr}
    bx lr

.error:
    mov r0, #1             @ Error code for out-of-range
    pop {r3, lr}
    bx lr
