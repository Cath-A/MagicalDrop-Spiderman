################# CSC258 Assembly Final Project ###################
# Keyboard input: detects a key press and dispatches it to logic.asm.
##############################################################################
.data
ADDR_KBRD:
    .word 0xffff0000

.include "macros.asm"
    .text

# Checks for a key press and handles it.
# Returns: v0 = 1 if a key was handled, 0 otherwise
handle_input:
    push($ra)

    lw   $t0, ADDR_KBRD
    lw   $t1, 0($t0)
    andi $t1, $t1, 1
    beq  $t1, $zero, no_key

    lw   $a0, 4($t0)
    jal  handle_keypress

    li   $v0, 1
    j handle_input_done

no_key:
    li   $v0, 0

handle_input_done:
    pop($ra)
    jr $ra

# Responds to keyboard keys.
# a0 = char of key pressed.
handle_keypress:
    push($ra)
    beq $a0, 0x71, respond_to_Q
    beq $a0, 0x61, respond_to_A
    beq $a0, 0x64, respond_to_D
    beq $a0, 0x73, respond_to_S
    beq $a0, 0x77, respond_to_W
    j keyboard_done

respond_to_Q:
    li $v0, 10                      # Quit gracefully
    syscall

respond_to_A:
    addi $a0, $zero, -1
    jal move_gwen
    j keyboard_done

respond_to_D:
    addi $a0, $zero, 1
    jal move_gwen
    j keyboard_done

respond_to_S:
    jal gwen_shoot
    j keyboard_done

respond_to_W:
    jal gwen_throw
    j keyboard_done

keyboard_done:
    pop($ra)
    jr $ra