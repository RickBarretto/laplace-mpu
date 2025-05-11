/*
 * Function: mpu_load
 * ---------------------
 * Loads a matrix from the FPGA memory (A or B) into the HPS memory by copying elements one by one.
 *
 * Uses the mapped MPU base address for register access.
 *
 * Registers used:
 * - r0: Holds mapped base address (must be set by caller)
 * - r1: Matrix selector (0 for A, 1 for B)
 * - r2: Pointer to HPS matrix base address (input)
 * - r3: Matrix size (number of elements to copy, input)
 * - r4: Temporary register for data transfer
 * - r5: Local copy of FPGA address pointer (offset from base)
 * - r6: Local copy of HPS address pointer
 * - r7: Local copy of matrix size counter
 *
 * Example:
 *   ```
 *   bl mpu_map_base_address   @ Get mapped base address in r0
 *   mov r1, #0                @ 0 for Matrix A, otherwise Matrix B
 *   ldr r2, =<hps_base_addr>  @ HPS matrix base address
 *   mov r3, #<matrix_size>    @ Number of elements
 *   bl mpu_load
 *   ```
 *
 * Note: Assumes r7 contains the mapped base address.
 */

#include "_mpu_constants.s"

.global mpu_load
.type mpu_load, %function

mpu_load:
    push {r4-r6, lr}

    cmp r1, #0                  @ Load B if r1 != 0
    bne load_matrix_b           @ Otherwise, load A

load_matrix_a:
    ldr r5, =MPU_MATRIX_A
    add r5, r0, r5              @ r5 = mapped_base + offset
    b   load_context

load_matrix_b:
    ldr r5, =MPU_MATRIX_B
    add r5, r0, r5              @ r5 = mapped_base + offset

load_context:
    ldr r6, [r2]                @ Load HPS matrix base address from r2
    mov r7, r3                  @ Load matrix size (number of elements) from r3

loop:
    cmp r7, #0                  @ Check if all elements are loaded
    beq load_done               @ If zero, exit loop

    ldrb r4, [r5], #1           @ Load byte from FPGA and increment FPGA address
    strb r4, [r6], #1           @ Store byte to HPS matrix and increment HPS address
    subs r7, r7, #1             @ Decrement matrix size counter
    b loop                      @ Repeat loop

load_done:
    pop {r4-r6, lr}
    bx lr
