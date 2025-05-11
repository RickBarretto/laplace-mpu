/*
 * Function: mpu_store
 * ----------------------
 * Stores a matrix from the HPS memory into the FPGA memory (A or B) by copying elements one by one.
 *
 * Registers used:
 * - r0: Matrix selector (0 for A, 1 for B)
 * - r1: Pointer to HPS base address (input)
 * - r2: Matrix size (number of elements to copy, input)
 * - r3: Temporary register for data transfer
 * - r4: Local copy of FPGA address pointer
 * - r5: Local copy of HPS address pointer
 * - r6: Local copy of matrix size counter
 *
 * Notes:
 * - The function uses a loop to copy each byte from the HPS to the selected FPGA matrix.
 * - The function preserves r4, r5, r6, and lr on the stack.
 * - The function returns when all elements have been copied.
 *
 * Example:
 *   Set up the registers before calling:
 *   ```
 *   mov r0, #0                @ 0 for Matrix A, otherwise, Matrix B
 *   ldr r1, =<hps_base_addr>  @ HPS base address
 *   mov r2, #<matrix_size>    @ Number of elements
 *   bl mpu_store
 *   ```
 */

#include "_mpu_constants.s"

.global mpu_store
.type mpu_store, %function

mpu_store:
    push {r4, r5, r6, lr}

    cmp r0, #0                  @ Load B if r0 != 0
    bne load_matrix_b           @ Otherwise, load A

load_matrix_a:
    ldr r4, =MPU_MATRIX_A
    b   load_context

load_matrix_b:
    ldr r4, =MPU_MATRIX_B

load_context:
    ldr r5, [r1]                @ Load HPS base address from r1
    mov r6, r2                  @ Load matrix size (number of elements) from r2

loop:
    cmp r6, #0                  @ Check if all elements are stored
    beq store_done              @ If zero, exit loop

    ldrb r3, [r5], #1           @ Load byte from HPS and increment HPS address
    strb r3, [r4], #1           @ Store byte to FPGA matrix and increment FPGA address
    subs r6, r6, #1             @ Decrement matrix size counter
    b loop                      @ Repeat loop

    @ Finish
    pop {r4, r5, r6, lr}
    bx lr
