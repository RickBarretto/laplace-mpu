/*
 * Function: mpu_mul_by_scalar
 * --------------------
 * Triggers the FPGA to perform a matrix multiplication by scalar operation by passing the opcode and storing the scalar value.
 *
 * Registers used:
 * - r0: Scalar value (byte to store)
 * - r3: Temporary register
 *
 * Notes:
 * - This function writes the scalar value to the FPGA scalar register (MPU_SCALAR), then writes the opcode for scalar multiplication to the control register (MPU_OPCODE).
 * - The function preserves r3 and lr on the stack.
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