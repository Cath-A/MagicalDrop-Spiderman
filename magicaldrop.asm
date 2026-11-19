################# CSC258 Assembly Final Project ###################
# This file contains our implementation of Magical Drop.
#
# Student 1: Catherine Abdul-Samad, 1012118860
#
# We assert that the code submitted here is entirely our own 
# creation, and will indicate otherwise when it is not.
#
######################## Bitmap Display Configuration ########################
# - Unit width in pixels:       4
# - Unit height in pixels:      4
# - Display width in pixels:    512
# - Display height in pixels:   384
# - Base Address for Display:   0x10008000 ($gp)
##############################################################################
.include "macros.asm"
    .data
##############################################################################
# Immutable Data
##############################################################################
reserved_space:
    .space 16384
ADDR_DSPL:
    .word 0x10008000

##############################################################################
# Mutable Data
##############################################################################

##############################################################################
# Code
##############################################################################
	.text
	.globl main

    # Run the game.
main:
    lw $gp, ADDR_DSPL           # Set $gp to base display address (0x10008000)
    lw $s0, ADDR_DSPL
    # Initialize the game
    jal init_game
    jal refresh_screen

game_loop:
    # 1a. Check if key has been pressed
    jal check_keypress
    beq $v0, $zero, skip_keypress
    # 1b. Check which key has been pressed
    lw $a0, 4($t0)                              # a0 = the code of the char that was pressed
    jal handle_keypress
    jal refresh_screen
    # 2a. Check for collisions
    
	# 2b. Update locations (capsules)
skip_keypress:
    lb $t0, target_cycles
    lb $t1, num_cycles
    bne $t0, $t1, check_reveal
    
	jal shift_down
	sb $zero, num_cycles
    
	# 3. Draw the screen
	jal refresh_screen
	j sleep
    
check_reveal:
    srl $t2, $t0, 1
    bne $t1, $t2, sleep
    jal refresh_screen

	# 4. Sleep
sleep:
	addi $v0, $zero, 32
	addi $a0, $zero, 16
	syscall
	   
	lb $t0, num_cycles
	addiu $t0, $t0, 1
	sb $t0, num_cycles
	   
    # 5. Go back to Step 1
    j game_loop
    
refresh_screen:
    push($ra)
    lw $a0, gwen_prev_offset
    jal erase_gwen              # black out where she was
    jal draw_static_screen      # repaint water, skyline, frame over it
    lbu $t0, target_cycles
    srl $t0, $t0, 1
    lbu $t1, num_cycles
    sge $a0, $t1, $t0           # a0 = reveal flag
    lw $a1, gwen_offset         # a1 = gwen_offset
    la $a2, grid                # a2 = grid_ptr
    la $a3, new_bombs           # a3 = new_bombs_ptr
    jal draw_dynamic
    pop($ra)
    jr $ra

##############################################################################
# Subroutines / Included Modules
##############################################################################
.include "draw.asm"
.include "logic.asm"
.include "keyboard.asm"
