/*
 * Function: mpu_mul_by_scalar
 * --------------------
 * Triggers the FPGA to perform a matrix multiplication by scalar operation.
 *
 * Uses the mapped MPU base address for register access.
 *
 * Registers used:
 * - r0: Scalar value (byte to store)
 * - r1: Holds mapped base address (must be set by caller)
 * - r3: Temporary register
 *
 * Notes:
 * - This function writes the scalar and then the OPCODE to the registers.
 *
 * Example:
 *   bl mpu_map_base_address   @ Get mapped base address in r0
 *   mov r1, r0                @ Save mapped address
 *   mov r0, #<scalar_value>   @ Scalar value
 *   bl mpu_mul_by_scalar
 *
 * Note: Assumes r1 contains the mapped base address.
 */

#include "_mpu_constants.s"
#include "_mpu_op.s"

.global mpu_mul_by_scalar
.type mpu_mul_by_scalar, %function

mpu_mul_by_scalar:
    push {r3, lr}

    ldr r3, =MPU_SCALAR     @ Load offset of scalar register
    add r3, r1, r3          @ r3 = mapped_base + offset
    strb r0, [r3]           @ Store scalar value (byte) to FPGA scalar register

    mov r0, #OP_SMUL        @ Opcode for multiplication by scalar
    bl _mpu_call            @ Call helper to set AWAIT and trigger operation

    pop {r3, lr}
    bx lr