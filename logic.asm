################# CSC258 Assembly Final Project ##############################
# Game state and rules: the incoming row, the playfield grid, shifting.
##############################################################################
.include "macros.asm"

.eqv GRID_COLS 7            
.eqv GRID_ROWS 11           
.eqv NUM_COLOURS 4          
.eqv BOMB_EMPTY 4           # any index >= NUM_COLOURS means "no bomb"

    .data
num_cycles:
    .byte 0     # The number of sleep cycles passed since last row advancement
target_cycles:
    .byte 255   # The target number of cycles the program waits until it shifts 
                # the row. target_cycles * 0.016 = time in seconds
    .align 2
gwen_offset:    
    .word 39968          # byte offset from $gp of gwen's top left
gwen_prev_offset:
    .word 39968          # previous position for erasing
gwen_hold:
    .byte 4, 0             # the colour of the bomb gwen is holding, the number of bombs she is holding
    .align 2
# Each cell is one word: a colour index 0..3, or BOMB_EMPTY (4) for no bomb.
new_bombs:   
    .space 28           # GRID_COLS * 4 bytes: the incoming bombs
grid:       
    .space 308          # GRID_COLS * GRID_ROWS * 4 bytes, row-major
game_over:  
    .word 0             # becomes 1 when a shift is impossible

    .text

# Resets all game state.
init_game:
    push($ra)
    
    # fill the grid with BOMB_EMPTY
    la $t0, grid
    addi $t1, $zero, GRID_COLS
    addi $t2, $zero, GRID_ROWS
    mult $t1, $t2
    mflo $t1
    addi $t2, $zero, BOMB_EMPTY
    
    clear_loop:
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        addi $t1, $t1, -1
        bne $t1, $zero, clear_loop
        
    sw $zero, game_over
    jal generate_random_bombs
    
    pop($ra)
    jr $ra
    
# Fills next_row with random colour indices 0..3.
generate_random_bombs:
    la $t0, new_bombs
    addi $t1, $zero, GRID_COLS
    
    generate_loop:
        add $v0, $zero, 42              # syscall 42: random int in [0, $a1)
        add  $a0, $zero, $zero          # generator id 0
        addi $a1, $zero, NUM_COLOURS
        syscall
        sw $a0, 0($t0)
        addi $t0, $t0, 4
        addi $t1, $t1, -1
        bne $t1, $zero, generate_loop
    jr $ra

# Shifts every bomb in the grid down one row, drops next_row into the top
# row, then generates a new next_row. If the bottom row already holds a bomb
# nothing moves and game_over is set to 1 instead.
shift_down:
    push($ra)
    
    addi $t0, $zero, GRID_COLS
    addi $t1, $zero, GRID_ROWS
    addi $t1, $t1, -1
    mult $t0, $t1
    mflo $t2
    la $t3, grid
    
    # 1. game over if the bottom row already holds a bomb
    sll $t4, $t2, 2
    add $t4, $t3, $t4       # first cell of the bottom row
    add $t5, $t0, $zero     # cells left to check
    
    check_game_over:
        lw $t6, 0($t4)
        sltiu $t7, $t6, NUM_COLOURS     # 1 if the cell holds a bomb
        bne $t7, $zero, set_game_over
        addi $t4, $t4, 4
        addi $t5, $t5, -1
        bne $t5, $zero, check_game_over
    
    # 2. move every bomb down by one
    addi $t4, $t2, -1
    sll $t4, $t4, 2
    add $t4, $t3, $t4
    sll $t6, $t0, 2
    add $t5, $t2, $zero
    
    shift_bomb:
        lw $t7, 0($t4)
        add $t8, $t4, $t6
        sw $t7, 0($t8)
        addi $t4, $t4, -4
        addi $t5, $t5, -1
        bne $t5, $zero, shift_bomb
    
    # 3. new_bombs become the top row of the grid
    la $t4, new_bombs
    add $t5, $t3, $zero
    add $t6, $t0, $zero
    
    add_bomb:
        lw $t7, 0($t4)
        sw $t7, 0($t5)
        addi $t4, $t4, 4
        addi $t5, $t5, 4
        addi $t6, $t6, -1
        bne $t6, $zero, add_bomb
    
    # 4. new incoming row
    jal generate_random_bombs
    j shift_done
    
    set_game_over:
        addi $t0, $zero, 1
        sw $t0, game_over
    
shift_done:
    pop($ra)
    jr $ra
    
# Move Gwen. If a0 = 1 then she will move right and if a0 = -1 then she will move left.
move_gwen:
    push($ra)
    lw $t0, gwen_offset
    sll $t1, $a0, 4
    add $t2, $t0, $t1

    li $t3, 39948               # left limit
    blt $t2, $t3, move_gwen_done
    li $t3, 40140               # right limit
    bgt $t2, $t3, move_gwen_done

    # Save previous position for erasing, then update current position
    sw $t0, gwen_prev_offset
    sw $t2, gwen_offset

move_gwen_done:
    pop($ra)
    jr $ra
    
gwen_shoot:
    push($ra)
    lw $t0, gwen_offset
    # 1. Loop up until hit a bomb
    
    # 2. Check what gwen holding, if >= 4 then take the bomb
    # 3. If not, check what the bomb is, compare to what gwen has
    # 4. If match, also take the bomb
    # 5. Taking the bomb
    take_bomb:
        # 5.1 Replace current bomb location with a 4
        # 5.2 Set the colour of gwen holding (# Pre: no illegal bomb colour mixing)
        # 5.3 Increment how much she's holding
    
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
	j keyboard_done
	
keyboard_done:
    pop($ra)
    jr $ra
