/*
 * Function: mpu_map_base_address
 * ------------------------------
 * Maps the MPU base address using /dev/mem and returns the mapped pointer.
 *
 * Return:
 *   r0: mapped base address pointer (or does not return on error)
 *
 * Example:
 *   ```
 *   bl mpu_map_base_address
 *   @ r0 now contains the mapped pointer
 *   ```
 *
 *
 * Function: close
 * ---------------
 * Closes a file descriptor.
 *
 * Arguments:
 *   r0: file descriptor to close
 *
 * Example:
 *   ```
 *   mov r0, <fd>   @ File Descriptor
 *   bl close
 *   ```
 */

#include "_mpu_constants.s"

.global _mpu_map_base_address
.type _mpu_map_base_address, %function
.global _mpu_close
.type _mpu_close, %function

_mpu_map_base_address:
    push {r0-r8, lr}

    @ Call open("/dev/mem") with O_RDWR|O_SYNC
    ldr r0, =open_path      @ r0 = "/dev/mem" string
    mov r1, #2              @ O_RDWR = 2
    orr r1, r1, #0x1000     @ O_SYNC = 0x1000
    mov r7, #5              @ syscall: open
    svc 0                   @ fd = open("/dev/mem", O_RDWR|O_SYNC)

    @ Open if status == -1
    cmp r0, #-1
    bne .opened

    @ Panic: could not open /dev/mem
    ldr r0, =err_open
    bl panic

.opened:

    @ Memory Mapping
    @ --------------

    @ Initialization
    mov r4, r0              @ Save File Descriptor
    mov r0, #0              @ Addr = NULL

    ldr r1, =MPU_SPAN_ADDRESS   @ Span Address
    ldr r2, =0x3                @ PROT_READ|PROT_WRITE
    ldr r3, =0x01               @ MAP_SHARED
    mov r7, #192                @ syscall: mmap2 (Linux ARM EABI)
    ldr r5, =MPU_BASE_ADDRESS   @ Load Base Address
    mov r6, r4                  @ File Descriptor
    
    @ Offset
    mov r8, #0              @ offset = base address >> 12 (for mmap2)
    add r8, r5, #0
    lsr r8, r8, #12
    mov r5, r8
    
    svc 0                   @ r0 = mmap(NULL, span, prot, flags, fd, offset)

    @ Mapped if status == 0
    cmp r0, #-1
    bne .mapped

    @ Panic mmap() failed
    ldr r0, =err_mmap
    bl panic

.mapped:
    pop {r0-r8, lr}
    bx lr


@ --------------------------------------------------------------

_mpu_close:
    push {r0, r7, lr}

    @ Close with syscall
    mov r7, #6              @ syscall: close
    svc 0                   @ close(fd)

    pop {r0, r7, lr}
    bx lr

.section .rodata
open_path: .asciz "/dev/mem"
err_open:  .asciz "ERROR: could not open /dev/mem/"
err_mmap:  .asciz "ERROR: mmap() failed..."
