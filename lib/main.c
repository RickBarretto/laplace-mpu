#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <time.h>
#include <stdint.h>

#define LW_BRIDGE_BASE   0xFF200000u
#define LW_BRIDGE_SPAN   0x00005000u
#define PIO_CMD_OFFSET   0x00u
#define PIO_STAT_OFFSET  0x10u

#define DIM              5
#define N_BYTES          (DIM * DIM)
#define N_BITS           (N_BYTES * 8u)

static void delay_1us(void)
{
    struct timespec ts = { .tv_sec = 0, .tv_nsec = 1000L };
    nanosleep(&ts, NULL);
}

static int open_dev(void)
{
    int fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) {
        perror("open(/dev/mem)");
        exit(EXIT_FAILURE);
    }
    return fd;
}

static void *map_hps(int fd)
{
    void *base = mmap(NULL, LW_BRIDGE_SPAN, PROT_READ | PROT_WRITE, MAP_SHARED, fd, LW_BRIDGE_BASE);
    if (base == MAP_FAILED) {
        perror("mmap");
        close(fd);
        exit(EXIT_FAILURE);
    }
    return base;
}

static void unmap_hps(void *base)
{
    if (munmap(base, LW_BRIDGE_SPAN) != 0) {
        perror("munmap");
        exit(EXIT_FAILURE);
    }
}

int main(void)
{
    volatile uint32_t *pio_cmd, *pio_stat;
    void              *hps_base;
    int                fd;
    uint32_t           status, base_cmd, bit_val;
    uint8_t            A[DIM][DIM], B[DIM][DIM], R[DIM][DIM];
    unsigned           op_code;
    unsigned           matrix_size;
    unsigned           matrix_size_bit;
    int                row, col;
    size_t             bit_pos, byte_idx;
    int                bit_idx;
    uint32_t           pos;

    // 0) Escolher operação
    printf("Digite o código da operação (0..7): ");
    if (scanf("%u", &op_code) != 1 || op_code > 7) {
        fprintf(stderr, "Operação inválida. Deve ser 0..7\n");
        return EXIT_FAILURE;
    }

    // 1) Se determinante, pedir tamanho (2 ou 3)
    if (op_code == 5) {
        printf("Digite o tamanho da matriz (2 ou 3): ");
        if (scanf("%u", &matrix_size) != 1 || (matrix_size != 2 && matrix_size != 3)) {
            fprintf(stderr, "Tamanho inválido. Deve ser 2 ou 3\n");
            return EXIT_FAILURE;
        }
        matrix_size_bit = (matrix_size == 2) ? 1 : 0;  // 1 para 2x2, 0 para 3x3
    } else {
        matrix_size_bit = 0;  // Ignorado em outras operações
    }

    // 2) Monta comando base
    base_cmd = ((op_code & 0x7u) << 27);
    if (op_code == 5) {
        base_cmd |= (matrix_size_bit << 30);  // Só usa o bit 30
    }

    // 3) Preencher matrizes A e B
    for (row = 0; row < DIM; row++) {
        for (col = 0; col < DIM; col++) {
            A[row][col] = (uint8_t)(row * DIM + col + 1);
            B[row][col] = (uint8_t)(DIM * DIM + 1 - A[row][col]);
            R[row][col] = 0;
        }
    }

    // 4) Acesso à FPGA
    fd       = open_dev();
    hps_base = map_hps(fd);
    pio_cmd  = (volatile uint32_t *)((char*)hps_base + PIO_CMD_OFFSET);
    pio_stat = (volatile uint32_t *)((char*)hps_base + PIO_STAT_OFFSET);

    // 5) Pulso inicial: IDLE → LOAD_A
    *pio_cmd = base_cmd | (1u << 31);
    *pio_cmd = base_cmd;
    delay_1us();

    // 6) LOAD_A: envia bits da matriz A
    for (bit_pos = 0; bit_pos < N_BITS; bit_pos++) {
        byte_idx = bit_pos >> 3;
        bit_idx  = bit_pos & 0x7;
        row      = byte_idx / DIM;
        col      = byte_idx % DIM;
        bit_val  = (A[row][col] >> bit_idx) & 1u;

        *pio_cmd = base_cmd | (1u << 31) | ((uint32_t)bit_pos << 1) | bit_val;
        delay_1us();
        *pio_cmd = base_cmd;
        delay_1us();
    }

    // 7) LOAD_B: envia bits da matriz B
    for (bit_pos = 0; bit_pos < N_BITS; bit_pos++) {
        byte_idx = bit_pos >> 3;
        bit_idx  = bit_pos & 0x7;
        row      = byte_idx / DIM;
        col      = byte_idx % DIM;
        bit_val  = (B[row][col] >> bit_idx) & 1u;

        *pio_cmd = base_cmd | (1u << 31) | ((uint32_t)bit_pos << 1) | bit_val;
        delay_1us();
        *pio_cmd = base_cmd;
        delay_1us();
    }

    // 8) EXEC_OP → READ_RES
    *pio_cmd = base_cmd | (1u << 31);
    *pio_cmd = base_cmd;
    delay_1us();

    // 9) Leitura do resultado
    for (byte_idx = 0; byte_idx < N_BYTES; byte_idx++) {
        *pio_cmd = base_cmd | (1u << 31);
        *pio_cmd = base_cmd;
        delay_1us();

        status = *pio_stat;
        pos    = (status >> 26) & 0x1Fu;
        row    = pos / DIM;
        col    = pos % DIM;
        R[row][col] = (uint8_t)(status & 0xFFu);

        *pio_cmd = base_cmd | (1u << 26);
        *pio_cmd = base_cmd;
        delay_1us();
    }

    // 10) Exibir resultado
    printf("\nResultado (op_code=%u):\n", op_code);
    for (row = 0; row < DIM; row++) {
        for (col = 0; col < DIM; col++) {
            printf("%4u", R[row][col]);
        }
        putchar('\n');
    }

    // 11) Finalização
    unmap_hps(hps_base);
    close(fd);
    return EXIT_SUCCESS;
}

