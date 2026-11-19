################# CSC258 Assembly Final Project ###################
# This file handles keyboard input checking.
##############################################################################
# The address of the keyboard. Don't forget to connect it!
.data
ADDR_KBRD:
    .word 0xffff0000

    .text

check_keypress:
    lw $t0, ADDR_KBRD
    lw $t1, 0($t0)
    add $v0, $t1, $zero
    jr $ra
