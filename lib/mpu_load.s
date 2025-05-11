/*
 * Function: mpu_load
 * ---------------------
 * Loads a matrix from the FPGA memory (A or B) into the HPS memory by copying elements one by one.
 *
 * Uses the mapped MPU base address for register access.
 *
 * Registers used:
 * - r0: Matrix selector (0 for A, 1 for B)
 * - r1: Pointer to HPS matrix base address (input)
 * - r2: Matrix size (number of elements to copy, input)
 * - r3: Temporary register for data transfer
 * - r4: Local copy of FPGA address pointer (offset from base)
 * - r5: Local copy of HPS address pointer
 * - r6: Local copy of matrix size counter
 * - r7: Holds mapped base address (must be set by caller)
 *
 * Example:
 *   ```
 *   bl mpu_map_base_address   @ Get mapped base address in r0
 *   mov r7, r0                @ Save mapped address
 *   mov r0, #0                @ 0 for Matrix A, otherwise Matrix B
 *   ldr r1, =<hps_base_addr>  @ HPS matrix base address
 *   mov r2, #<matrix_size>    @ Number of elements
 *   bl mpu_load
 *   ```
 *
 * Note: Assumes r7 contains the mapped base address.
 */

#include "_mpu_constants.s"

.global mpu_load
.type mpu_load, %function

mpu_load:
    push {r4, r5, r6, lr}

    cmp r0, #0                  @ Load B if r0 != 0
    bne load_matrix_b           @ Otherwise, load A

load_matrix_a:
    ldr r4, =MPU_MATRIX_A
    add r4, r7, r4              @ r4 = mapped_base + offset
    b   load_context

load_matrix_b:
    ldr r4, =MPU_MATRIX_B
    add r4, r7, r4              @ r4 = mapped_base + offset

load_context:
    ldr r5, [r1]                @ Load HPS matrix base address from r1
    mov r6, r2                  @ Load matrix size (number of elements) from r2

loop:
    cmp r6, #0                  @ Check if all elements are loaded
    beq load_done               @ If zero, exit loop

    ldrb r3, [r4], #1           @ Load byte from FPGA and increment FPGA address
    strb r3, [r5], #1           @ Store byte to HPS matrix and increment HPS address
    subs r6, r6, #1             @ Decrement matrix size counter
    b loop                      @ Repeat loop

load_done:
    pop {r4, r5, r6, lr}
    bx lr
