/*
 * Function: mpu_mul_by_scalar
 * --------------------
 * Triggers the FPGA to perform a matrix multiplication by scalar operation.
 *
 * Registers used:
 * - r0: Scalar value (byte to store)
 * - r3: Temporary register
 *
 * Notes:
 * - This function writes the scalar and then the OPCODE to the registers.
 *
 * Example:
 *   Set up the registers before calling:
 *   ```
 *   mov r0, #<scalar_value>      @ Scalar value
 *   bl mpu_mul_by_scalar
 *   ```
 */

#include "_mpu_constants.s"
#include "_mpu_op.s"

.global mpu_mul_by_scalar
.type mpu_mul_by_scalar, %function

mpu_mul_by_scalar:
    push {r3, lr}

    @ Store scalar
    ldr r3, =MPU_SCALAR     @ Load address of scalar register
    strb r0, [r3]           @ Store scalar value (byte) to FPGA scalar register

    mov r0, #OP_SMUL        @ Opcode for multiplication by scalar
    bl _mpu_call            @ Call helper to set AWAIT and trigger operation

    pop {r3, lr}
    bx lr