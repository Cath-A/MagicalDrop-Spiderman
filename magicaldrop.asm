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
.include "macros.asm"

##############################################################################
# Constants
##############################################################################
.eqv GRID_COLS 7
.eqv GRID_ROWS 10
.eqv NUM_COLOURS 4
.eqv BOMB_EMPTY 4            # any index >= NUM_COLOURS means "no bomb"
.eqv NEXT_ROW_OFFSET 32      # incoming row, rows 0-6
.eqv BOMB_OFFSET 4128        # playfield top left, row 8
.eqv WEB_DASH 3
.eqv WEB_GAP 2
.eqv GOBLIN_BOMB_OFFSET 4620 # offset from goblin's top left row
.eqv GOBLIN_BOB_RANGE 6
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
# Gwen
gwen_offset:
    .word 40480          # byte offset from $gp of gwen's top left
gwen_prev_offset:
    .word 40480          # previous position for erasing
gwen_hold:
    .byte BOMB_EMPTY, 0  # colour of the bombs she holds (BOMB_EMPTY = none), 
    .align 2             # how many bombs she holds
gwen_col:       
    .word 0              # the column gwen is in
# Green Goblin
goblin_offset:
    .word 260          # byte offset from $gp of his top left
goblin_prev_offset:
    .word 260          # previous position for erasing
goblin_bomb_colour: 
    .word 3
goblin_dir:
    .word 1
goblin_y:
    .word 0
# Web
web_visible:
    .word 0              # 1 = visible, 0 = hidden
web_addr:
    .word 0
web_height:
    .word 0
web_cap_addr:
    .word 0
# Timing
cycles:
    .word 0, 500         # sleep cycles passed since the last row advancement, 
                         # cycles until the row shifts (target_cycles * 0.016 = seconds)
    .align 2
time:
    .word 0              # global relative time to base state off of 
# Playfield (each cell is one word: colour index 0..3, or BOMB_EMPTY)
new_bombs:
    .space 28            # GRID_COLS * 4 bytes: the incoming bombs
bombs:
    .space 280           # GRID_COLS * GRID_ROWS * 4 bytes, row-major
game_over:
    .word 0              # becomes 1 when a shift is impossible

##############################################################################    
# Code
##############################################################################
	.text
	.globl main
    # Run the game.
main:
    lw $gp, ADDR_DSPL
    # Initialize the game
    jal init_game
    jal refresh_screen

game_loop:
    # 1a. Check if key has been pressed
    jal handle_input
    beq $v0, $zero, skip_keypress
    jal refresh_screen
    
	# 2 Update locations
    skip_keypress:
    jal apply_gravity
    jal animate_web
    jal animate_green_goblin
    
    la $t3, cycles
    lw $t0, 4($t3)
    lw $t1, 0($t3)

    bne $t0, $t1, check_reveal
    
	jal shift_down
	la $t3, cycles
	sw $zero, 0($t3)
    
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
	   
	la $t3, cycles
	lw $t0, 0($t3)
	addiu $t0, $t0, 1
	sw $t0, 0($t3)
	
	lw $t0, time
	addiu $t0, $t0, 1
	sw $t0, time
	   
    # 5. Go back to Step 1
    j game_loop


refresh_screen:
    push($ra)
    jal erase_gwen              # black out where she was
    jal draw_static_screen      # repaint water, skyline, frame over it
    
    la $t2, cycles
    lw $t0, 0($t2)             # t0 = current sleep cycle
    lw $t1, 4($t2)             # t1 = target sleep cycles
    srl $t1, $t1, 1             # t1 = target sleep cycles / 2
    sge $a0, $t0, $t1           # a0 = reveal flag
    jal draw_dynamic
    
    pop($ra)
    jr $ra

##############################################################################
# Included Modules
##############################################################################
.include "draw.asm"
.include "logic.asm"
.include "keyboard.asm"