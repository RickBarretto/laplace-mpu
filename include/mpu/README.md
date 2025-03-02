# MPU

Matrix Processing Unit (MPU) is responsible for operating matrix.
This module will simulate each operation allowed for our co-processor made in Verilog VHDL.

The idea here is to first simulate how the processing works, 
for this, we should not use any loop at MPU scope, but at APP scope.

## Requirements
* Matrix's size must be N x N | N <= 5
* Each element must be an 8-bits integer
* Architecture based on Pipeline & Parallelism

## Operations

* [x] Addition of matrices
* [x] Subtraction of matrices
* Multiplication of matrices
* [x] Multiplication of a matrix by integer
* Determinant
* Matrix transposition
* [x] Opposite matrix