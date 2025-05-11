@ Assembly definitions for matrix hardware addresses and opcodes

.equ MPU_BASE_ADDRESS, 0xFF200000
.equ MPU_SPAN_ADDRESS, 0x00005000

.equ MPU_OPCODE,   0xFF200000  @ Address for op-code register   (1 byte)
.equ MPU_AWAIT,    0xFF1FFFFF  @ Address for MPU AWAIT Flag     (1 byte)

.equ MPU_MATRIX_A, 0xFF1FFFFC  @ Address for Matrix A           (25 bytes)
.equ MPU_MATRIX_B, 0xFF1FFFD7  @ Address for Matrix B           (25 bytes)
.equ MPU_SCALAR,   0xFF1FFFB2  @ Address for scalar value       (1 byte)
.equ MPU_SIZE,     0xFF1FFFB2  @ Address for matrix size        (1 byte)

.equ OP_ADD,  0                @ Opcode for addition
.equ OP_SUB,  1                @ Opcode for subtraction
.equ OP_SMUL, 2                @ Opcode for multiplication by scalar
.equ OP_OPP,  3                @ Opcode for opposite matrix
.equ OP_TRS,  4                @ Opcode for transpose matrix
.equ OP_DET,  5                @ Opcode for determinant
.equ OP_MUL,  6                @ Opcode for multiplication
.equ OP_NOP,  7                @ No-Operation
