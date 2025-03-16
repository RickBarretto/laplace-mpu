#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>

#define FPGA_BASE  0xC0000000
#define LIGHTWEIGHT_BASE 0xFF200000
#define FPGA_TO_HPS  0xC0100000
#define FPGA_SPAN  0x00200000

#define panic(format, ...)                      \
        fprintf(stderr, "Panic: ");             \
        fprintf(stderr, format, __VA_ARGS__);   \
        fprintf(stderr, "\n");                  \
        exit(EXIT_FAILURE);

#define map_memory(address)     \
        mmap(NULL, FPGA_SPAN, PROT_READ | PROT_WRITE, MAP_SHARED, file, address)

int main()
{
        int file = open("/dev/mem/", O_RDWR | O_SYNC);
        if (file == -1) panic("Could not open /dev/mem/");

        void *fpga_base = map_memory(FPGA_BASE);
        volatile unsigned int *write = fpga_base;

        void *lightweight_base = map_memory(LIGHTWEIGHT_BASE);
        volatile unsigned int *instruction = lightweight_base;

        void *fpga_result = map_memory(FPGA_TO_HPS);
        volatile unsigned int *read = fpga_result;

        write[0] = 5;
        write[1] = 7;

        instruction[0] = 1;

        // wait for ready flag
        while (read[1] == 0);
        
        // Program
        printf("Resultado da soma: %d\n", read[0]);

        // Resetar flag de pronto
        read[1] = 0;

        munmap(fpga_base, FPGA_SPAN);
        munmap(lightweight_base, FPGA_SPAN);
        munmap(fpga_result, FPGA_SPAN);
        close(file);
}