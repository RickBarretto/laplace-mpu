#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>     /* open, close */
#include <fcntl.h>      /* O_RDWR, O_SYNC */
#include <sys/mman.h>   /* mmap, munmap */
#include <time.h>       /* nanosleep */

#define LW_BRIDGE_BASE   0xFF200000u
#define LW_BRIDGE_SPAN   0x00005000u
#define PIO_CMD_OFFSET   0x00u
#define PIO_STAT_OFFSET  0x10u

#define DIM     5
#define N_BYTES (DIM * DIM)
#define N_BITS  (N_BYTES * 8u)

/* matrizes estáticas */
static unsigned char A[N_BYTES] = {
     1,  2,  3,  4,  5,
     6,  7,  8,  9, 10,
    11, 12, 13, 14, 15,
    16, 17, 18, 19, 20,
    21, 22, 23, 24, 25
};
static unsigned char B[N_BYTES] = {
    25, 24, 23, 22, 21,
    20, 19, 18, 17, 16,
    15, 14, 13, 12, 11,
    10,  9,  8,  7,  6,
     5,  4,  3,  2,  1
};
static unsigned char R[N_BYTES];

/* delay ≈1µs */
static void delay_1us(void)
{
    struct timespec ts;
    ts.tv_sec  = 0;
    ts.tv_nsec = 3000L;
    nanosleep(&ts, NULL);
}

/* abre /dev/mem */
static int open_dev(void)
{
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) {
        perror("open(/dev/mem)");
        exit(EXIT_FAILURE);
    }
    return fd;
}

/* mapeia lightweight bridge */
static void *map_hps(int fd)
{
    void *base = mmap(NULL,
                      LW_BRIDGE_SPAN,
                      PROT_READ | PROT_WRITE,
                      MAP_SHARED,
                      fd,
                      LW_BRIDGE_BASE);
    if (base == MAP_FAILED) {
        perror("mmap");
        close(fd);
        exit(EXIT_FAILURE);
    }
    return base;
}

/* desfaz mapeamento */
static void unmap_hps(void *base)
{
    if (munmap(base, LW_BRIDGE_SPAN) != 0) {
        perror("munmap");
        exit(EXIT_FAILURE);
    }
}

int main(void)
{
    volatile unsigned int *pio_cmd;
    volatile unsigned int *pio_stat;
    void    *hps_base;
    int      fd;
    unsigned op_code;
    unsigned base_cmd;
    unsigned size2_flag;
    unsigned status;
    unsigned bit_pos, byte_idx, bit_idx;
    unsigned i;

    /* lê código da operação */
    printf("Código da operação (0..7): ");
    if (scanf("%u", &op_code) != 1 || op_code > 7) {
        fprintf(stderr, "Operação inválida (0..7)\n");
        return EXIT_FAILURE;
    }

    /* prepara comando (flag de dimensão sempre 1 para 5×5) */
    size2_flag = 1u;
    base_cmd   = (size2_flag << 30) | ((op_code & 0x7u) << 27);

    /* abre e mapeia ponte HPS→FPGA */
    fd       = open_dev();
    hps_base = map_hps(fd);
    pio_cmd  = (volatile unsigned int *)((char *)hps_base + PIO_CMD_OFFSET);
    pio_stat = (volatile unsigned int *)((char *)hps_base + PIO_STAT_OFFSET);

    /* IDLE → LOAD_A (pulso inicial) */
    *pio_cmd = base_cmd | (1u << 31);
    *pio_cmd = base_cmd;
    delay_1us();

    /* LOAD_A: envia todos os bits de A */
    for (bit_pos = 0; bit_pos < N_BITS; bit_pos++) {
        byte_idx = bit_pos >> 3;
        bit_idx  = bit_pos & 0x7;
        status   = (A[byte_idx] >> bit_idx) & 1u;

        *pio_cmd = base_cmd | (1u << 31) | (bit_pos << 1) | status;
        *pio_cmd = base_cmd;
        delay_1us();
    }

    /* LOAD_B: envia todos os bits de B */
    for (bit_pos = 0; bit_pos < N_BITS; bit_pos++) {
        byte_idx = bit_pos >> 3;
        bit_idx  = bit_pos & 0x7;
        status   = (B[byte_idx] >> bit_idx) & 1u;

        *pio_cmd = base_cmd | (1u << 31) | (bit_pos << 1) | status;
        *pio_cmd = base_cmd;
        delay_1us();
    }

    /* EXEC_OP → READ_RES (pulso extra) */
    *pio_cmd = base_cmd | (1u << 31);
    *pio_cmd = base_cmd;
    delay_1us();

    /* READ_RES: lê N_BYTES e envia ACK */
    for (byte_idx = 0; byte_idx < N_BYTES; byte_idx++) {
        *pio_cmd = base_cmd | (1u << 31);
        *pio_cmd = base_cmd;
        delay_1us();

        status     = *pio_stat;
        R[byte_idx] = (unsigned char)(status & 0xFFu);

        *pio_cmd = base_cmd | (1u << 26);
        *pio_cmd = base_cmd;
        delay_1us();
    }

    /* imprime A */
    printf("\nMatriz A (%u×%u):\n", DIM, DIM);
    for (i = 0; i < N_BYTES; i++) {
        printf("%4u", A[i]);
        if ((i + 1) % DIM == 0) putchar('\n');
    }

    /* imprime B */
    printf("\nMatriz B (%u×%u):\n", DIM, DIM);
    for (i = 0; i < N_BYTES; i++) {
        printf("%4u", B[i]);
        if ((i + 1) % DIM == 0) putchar('\n');
    }

    /* imprime resultado */
    printf("\nResultado (op_code=%u, dim=%u):\n", op_code, DIM);
    for (i = 0; i < N_BYTES; i++) {
        printf("%4u", R[i]);
        if ((i + 1) % DIM == 0) putchar('\n');
    }

    /* cleanup */
    unmap_hps(hps_base);
    close(fd);
    return EXIT_SUCCESS;
}

