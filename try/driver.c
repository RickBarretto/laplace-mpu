#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <stdint.h>

#define HPS_FPGA_BRIDGE_BASE 0xC0000000
#define MATRIX_A_OFFSET 0x00
#define MATRIX_B_OFFSET 0x64
#define MATRIX_C_OFFSET 0xC8

int main() {
    int fd;
    volatile uint32_t *hps_fpga_addr;

    fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd == -1) {
        perror("open");
        return -1;
    }

    hps_fpga_addr = (volatile uint32_t *) mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, fd, HPS_FPGA_BRIDGE_BASE);
    if (hps_fpga_addr == MAP_FAILED) {
        perror("mmap");
        close(fd);
        return -1;
    }

    // Write elements to matrix A
    for (int i = 0; i < 25; i++) {
        hps_fpga_addr[(MATRIX_A_OFFSET / 4) + i] = i + 1;
    }

    // Write elements to matrix B
    for (int i = 0; i < 25; i++) {
        hps_fpga_addr[(MATRIX_B_OFFSET / 4) + i] = i + 1;
    }

    // Read and print elements of matrix C
    for (int i = 0; i < 25; i++) {
        uint32_t data = hps_fpga_addr[(MATRIX_C_OFFSET / 4) + i];
        printf("C[%d] = %d\n", i, data);
    }

    munmap((void *) hps_fpga_addr, 4096);
    close(fd);

    return 0;
}