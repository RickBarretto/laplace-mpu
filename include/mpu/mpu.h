#ifndef __MPU_H__
#define __MPU_H__

#include <mpu/common.h>
#include <mpu/matrix.h>

enum {
    MatrixWidth = 5
};

typedef enum {
    MpuAdd,     // 0b000
    MpuSub,     // 0b001
    MpuMul,     // 0b010
    MpuImul,    // 0b011
    MpuOpp,     // 0b100
    MpuTrp,     // 0b101
    MpuDet,     // 0b110
} MpuIntructions;

typedef struct {
    Matrix matrix_a;
    union { // 2nd input
        Matrix matrix_b;
        u8 integer;
    };
    union { // output
        Matrix matrix_out;
        i16 det;
    };
    u8 program_counter;
} MPU;


void execute_instruction(MPU *mpu, MpuIntructions instr);


#endif