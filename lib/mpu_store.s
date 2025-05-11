/*
 * Function: mpu_store
 * ----------------------
 * Stores a matrix from the HPS memory into the FPGA memory (A or B) by copying elements one by one.
 *
 * Uses the mapped MPU base address for register access.
 *
 * Registers used:
 * - r0: Holds mapped base address (must be set by caller)
 * - r1: Matrix selector (0 for A, 1 for B)
 * - r2: Pointer to HPS base address (input)
 * - r3: Matrix size (number of elements to copy, input)
 * - r4: Temporary register for data transfer
 * - r5: Local copy of FPGA address pointer (offset from base)
 * - r6: Local copy of HPS address pointer
 * - r7: Local copy of matrix size counter
 *
 * Notes:
 * - The function uses a loop to copy each byte from the HPS to the selected FPGA matrix.
 * - The function preserves r4, r5, r6, and lr on the stack.
 * - The function returns when all elements have been copied.
 *
 * Example:
 *   ```
 *   bl mpu_map_base_address   @ Get mapped base address in r0
 *   mov r1, #0                @ 0 for Matrix A, otherwise, Matrix B
 *   ldr r2, =<hps_base_addr>  @ HPS base address
 *   mov r3, #<matrix_size>    @ Number of elements
 *   bl mpu_store
 *   ```
 *
 * Note: Assumes r7 contains the mapped base address.
 */

#include "_mpu_constants.s"

.global mpu_store
.type mpu_store, %function

mpu_store:
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
    ldr r6, [r2]                @ Load HPS base address from r2
    mov r7, r3                  @ Load matrix size (number of elements) from r3

loop:
    cmp r7, #0                  @ Check if all elements are stored
    beq store_done              @ If zero, exit loop

    ldrb r4, [r6], #1           @ Load byte from HPS and increment HPS address
    strb r4, [r5], #1           @ Store byte to FPGA matrix and increment FPGA address
    subs r7, r7, #1             @ Decrement matrix size counter
    b loop                      @ Repeat loop

store_done:
    pop {r4-r6, lr}
    bx lr
