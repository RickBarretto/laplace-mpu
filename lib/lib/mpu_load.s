/*
 * Function: mpu_load
 * ---------------------
 * Loads a matrix from the FPGA memory (A or B) into the HPS memory by copying elements one by one.
 *
 * Registers used:
 * - r0: Matrix selector (0 for A, 1 for B)
 * - r1: Pointer to HPS matrix base address (input)
 * - r2: Matrix size (number of elements to copy, input)
 * - r3: Temporary register for data transfer
 * - r4: Local copy of FPGA address pointer
 * - r5: Local copy of HPS address pointer
 * - r6: Local copy of matrix size counter
 *
 * Example:
 *   Set up the registers before calling:
 *   ```
 *   mov r0, #0                @ 0 for Matrix A, otherwise Matrix B
 *   ldr r1, =<hps_base_addr>  @ HPS matrix base address
 *   mov r2, #<matrix_size>    @ Number of elements
 *   bl mpu_load
 *   ```
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
    b   load_context

load_matrix_b:
    ldr r4, =MPU_MATRIX_B

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

end_function:
    pop {r4, r5, r6, lr}
    bx lr
