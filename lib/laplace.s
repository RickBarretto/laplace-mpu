/*
 * laplace.s - Matrix operations library module
 *
 * Provides access to Matrix Operations to be used with the Laplace-MPU.
 *
 * Usage:
 *   (link this file with your main program)
 */

#include "_mpu_constants.s"

@ Exported functions
@ ==================

@ Data Functions
.global mpu_load
.global mpu_store

@ Arithmetic Function
.global mpu_add
.global mpu_sub
.global mpu_mul_by_scalar
.global mpu_opposite
.global mpu_transpose
.global mpu_determinant
.global mpu_multiply


@ Include the actual implementations
#include "mpu_add.s"
#include "mpu_sub.s"
#include "mpu_mul_by_scalar.s"
#include "mpu_opposite.s"
#include "mpu_transpose.s"
#include "mpu_determinant.s"
#include "mpu_multiply.s"
