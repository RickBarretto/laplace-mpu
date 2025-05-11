/*
 * Function: panic
 * --------------
 * Prints an error message and halts execution.
 *
 * Arguments:
 *   r0: pointer to error message (zero-terminated string)
 *
 * This function does not return.
 */

.global panic
.type panic, %function

panic:
    push {lr}

    bl puts         @ Print error message (r0 = pointer to string)

    mov r0, #-1     @ Exit code -1
    bl exit         @ Terminate program

    b .             @ Should never reach here
