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

typedef uint8_t Matrix[DIM][DIM];

typedef struct {
    volatile uint32_t *command, *feedback;
} PinIO;

typedef struct {
    void  *base;
    int   file;
} Connection;

typedef struct {
    uint32_t base;
    unsigned opcode, matrix_size;
} Instruction;

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


static volatile uint32_t build_base_cmd(Instruction i) {
    uint32_t cmd = (i.opcode & 0x7u) << 27;
    if (i.opcode == 5) cmd |= (size_code(i.matrix_size) << 30);
    return cmd;
}

static inline next_stage(volatile uint32_t *pio_cmd, uint32_t base_cmd) {
    *pio_cmd = base_cmd | (1u << 31);
    *pio_cmd = base_cmd;
    delay_1us();
}

static inline void mpu_store(Matrix A, volatile uint32_t *pio_cmd, uint32_t base_cmd) {
    size_t bit_pos, byte_idx;
    int bit_idx, row, col;
    uint32_t bit_val;

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
}

static inline void mpu_load(Matrix R, volatile uint32_t *pio_cmd, volatile uint32_t *pio_stat, uint32_t base_cmd) {
    size_t byte_idx;
    uint32_t status, pos;
    int row, col;

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
}

static inline void init_default_matrices(Matrix a, Matrix b, Matrix result) {
    int row, col;
    for (row = 0; row < DIM; row++) {
        for (col = 0; col < DIM; col++) {
            a[row][col] = (uint8_t)(row * DIM + col + 1);
            b[row][col] = (uint8_t)(DIM * DIM + 1 - a[row][col]);
            result[row][col] = 0;
        }
    }
}


int get_u8(char* message) {
    int value = -1;
    
    puts(message);
    printf(">>> ");
    
    if (scanf("%u", &value) != 1) {
        perror("Formato de entrada inválida. O mesmo deve ser do tipo u8.");
        return -1;
    } else {
        return value;
    }
}

int get_operation() {
    int operation = get_u8("Digite o código da operação (0..7):");
    
    if (operation < 0 || operation > 7) {
        perror("Operação inválida. Deve ser 0..7");
        return -1;
    }
}

int get_size_for_determinant() {
    int size = get_u8("Digite o tamanho da matriz (2 ou 3):");
    
    if (size < 2 || size > 3) {
        perror("Operação inválida. Deve ser 2..3");
        return -1;
    }
}

int size_code(int size) {
    return (size == 2) ? 1 : 0;
}

void print_matrix(char* section, Matrix matrix) {
    int row, col;
    puts("");
    puts(section);
    for (row = 0; row < DIM; row++) {
        for (col = 0; col < DIM; col++) {
            printf("%4u", matrix[row][col]);
        }
        putchar('\n');
    }
}

void display_result(Matrix A, Matrix B, Matrix R, unsigned op_code) {
    print_matrix("Matrix A:", A);
    print_matrix("Matrix B:", B);
    printf("\nOperation (%u)\n", op_code);
    print_matrix("Resultado:", R);
}

static inline int finish_app(int fd, void *hps_base) {
    unmap_hps(hps_base);
    close(fd);
    return EXIT_SUCCESS;
}

Connection new_connection() {
    Connection connection;
    connection.file = open_dev();
    connection.base = map_hps(connection.file);
    return connection;
}

int main(void)
{
    Connection connection;
    volatile PinIO pins;
    Instruction instruction;
    Matrix             A, B, R;
    
    connection = new_connection();
    pins.command = connection.base + PIO_CMD_OFFSET;
    pins.feedback = connection.base + PIO_STAT_OFFSET;
    
    init_default_matrices(A, B, R);
    instruction.opcode = get_operation();
    instruction.matrix_size = (instruction.opcode == 5)? get_size_for_determinant() : 0; 
    instruction.base = build_base_cmd(instruction);

    next_stage(pins.command, instruction.base);
    
    mpu_store(A, pins.command, instruction.base);
    mpu_store(B, pins.command, instruction.base);
    
    next_stage(pins.command, instruction.base);a
    mpu_load(R, pins.command, pins.feedback, instruction.base);

    display_result(A, B, R, instruction.opcode);
    return finish_app(connection.file, connection.base);
}

