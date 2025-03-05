#include <stdio.h>
#include <stdlib.h>
#include <mpu/mpu.h>

void execute_instruction(MPU *mpu, MpuIntructions instr){
    #define INPUT_A    (mpu->matrix_a)
    #define INPUT_B    (mpu->matrix_b)
    #define INPUT_I    (mpu->integer)
    #define OUTPUT     (mpu->matrix_out)
    #define OUTPUT_DET (mpu->det)
    
    switch (instr)
    {
    case MpuAdd:  mpu_add(&INPUT_A, &INPUT_B, &OUTPUT);
    case MpuSub:  mpu_sub(&INPUT_A, &INPUT_B, &OUTPUT);
    case MpuMul:  mpu_mul(&INPUT_A, &INPUT_B, &OUTPUT);
    case MpuImul: mpu_imul(&INPUT_A, INPUT_I, &OUTPUT);
    case MpuOpp:  mpu_opposite(&INPUT_A, &OUTPUT);
    case MpuTrp:  mpu_transpose(&INPUT_A, &OUTPUT);
    case MpuDet:  mpu_det(&INPUT_A, &OUTPUT_DET);
    default:
        fprintf(stderr, "Unknown instruction.");
        exit(1);
    }
}
