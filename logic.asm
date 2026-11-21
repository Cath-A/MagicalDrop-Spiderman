################# CSC258 Assembly Final Project ##############################
# Game state and rules: the incoming row, the playfield grid, shifting.
##############################################################################
.include "macros.asm"
    .data
    .text

# Resets all game state.
init_game:
    push($ra)
    # fill the grid with BOMB_EMPTY
    la $t0, bombs
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
    la $t3, bombs
    
    # 1. game over if the row above already holds a bomb
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

    li $t3, 40460               # left limit
    blt $t2, $t3, move_gwen_done
    li $t3, 40652               # right limit
    bgt $t2, $t3, move_gwen_done

    # Save previous position for erasing, then update current position
    sw $t0, gwen_prev_offset
    sw $t2, gwen_offset

move_gwen_done:
    pop($ra)
    jr $ra

# Finds the nearest bomb above Gwen in her current location.
#
# Returns:
#   v0 = index of bomb's colour, -1 if no bomb found
#   v1 = bomb offset
#   a0 = address of bomb's cell in bomb array
#   a1 = Gwen's column, -1 if she is outside the grid
find_bomb:
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    
    # 1. Calculate Gwen's centre x-coordinate in pixels
    lw $t0, gwen_offset
    andi $t0, $t0, 511      # isolate horizontal byte offset
    srl $t0, $t0, 2         # convert bytes to pixels
    addi $t0, $t0, 5        # Gwen's centre is 5 pixels from left
    
    # 2. Calculate which grid column she's in
    addi $t0, $t0, -8
    bltz $t0, bomb_outside
    addi $t1, $zero, 7
    divu $t0, $t1
    mflo $s3
    
    sltiu $t1, $s3, GRID_COLS
    beq $t1, $zero, bomb_outside
    
    # 3. Start at the bottom row of the bombs array
    la $s0, bombs
    addi $s0, $s0, 252
    sll $t0, $s3, 2
    add $s0, $s0, $t0
    
    # 4. Calculate the screen offset of that bomb
    addi $s1, $zero, 36384
    
    # Add column * 28
    sll $t0, $s3, 2
    sll $t1, $s3, 3
    add $t0, $t0, $t1
    sll $t1, $s3, 4
    add $t0, $t0, $t1
    add $s1, $s1, $t0       # s1 = bomb's screen offset
    
    addi $s2, $zero, GRID_ROWS
    
    find_bomb_loop:
        lw $t0, 0($s0)
        sltiu $t1, $t0, NUM_COLOURS
        bne $t1, $zero, bomb_found
        addi $s0, $s0, -28
        addi $s1, $s1, -3584
        addi $s2, $s2, -1
        bne $s2, $zero, find_bomb_loop
        
    # column is empty
    addi $v0, $zero, -1
    add $v1, $zero, $zero
    add $a0, $zero, $zero
    add $a1, $s3, $zero
    j find_bomb_done
    
    bomb_outside:
        addi $v0, $zero, -1
        add $v1, $zero, $zero
        add $a0, $zero, $zero
        addi $a1, $zero, -1
        j find_bomb_done
    
    bomb_found:
        add $v0, $t0, $zero
        add $v1, $s1, $zero
        add $a0, $s0, $zero
        add $a1, $s3, $zero
        
    find_bomb_done:
        pop($s3)
        pop($s2)
        pop($s1)
        pop($s0)
        jr $ra

gwen_shoot:
    push($ra)
    #   v0 = index of bomb's colour, -1 if no bomb found
    #   v1 = bomb offset
    #   a0 = address of bomb's cell in bomb array
gwen_shoot_loop:
    jal find_bomb
    blt $v0, $zero, end_gwen_shoot 
    la $t2, gwen_hold
    lbu $t0, 0($t2)
    beq $t0, BOMB_EMPTY, gwen_bomb_found
    bne $t0, $v0, end_gwen_shoot
    
gwen_bomb_found:
    lbu $t1, 1($t2)
    addi $t1, $t1, 1
    sb $t1, 1($t2)
    sb $v0, 0($t2)
    
    addi $t3, $zero, BOMB_EMPTY
    sw $t3, 0($a0)
    
    add $a0, $gp, $v1                  
    addi $a1, $zero, 7                  
    addi $a2, $zero, 7              
    add $a3, $zero, $zero
    jal rectangle
    
    j gwen_shoot_loop
    
end_gwen_shoot:
    pop($ra)
    jr $ra
    
    
gwen_throw:
    push($ra)
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    push($s4)
    # 1) check if she even has a bombs, if not go to end_gwen_throw
    la $s0, gwen_hold
    lbu $s1, 1($s0)                     # how many bombs she has
    beq $s1, $zero, end_gwen_throw
    #   a0 = address of bomb's cell in bomb array
    jal find_bomb
    bltz $a1, end_gwen_throw 
    bltz $v0, throw_top_cell
    
    addi $s2, $a0, 28                   # new bomb next location
    add $s4, $gp, $v1
    addi $s4, $s4, 3584                 # new bomb next address
    j throw_set_limit
    
throw_top_cell:
    la $s2, bombs 
    sll $t0, $a1, 2
    add $s2, $s2, $t0                   # grid: bombs + 4col
    
    addi $t1, $zero, 28
    mult $a1, $t1
    mflo $t0
    addi $t0, $t0, BOMB_OFFSET
    add $s4, $gp, $t0                   # screen: gp + BOMB_OFFSET + 28col

throw_set_limit:
    la $s3, bombs 
    addi $s3, $s3, 252

gwen_throw_loop:
    beq $s1, $zero, end_gwen_throw
    bge $s2, $s3, end_gwen_throw
    
    lbu $a1, 0($s0)
    sw $a1, 0($s2)
    add $a0, $s4, $zero
    jal draw_bomb
    
    addi $s2, $s2, 28
    addi $s4, $s4, 3584
    addi $s1, $s1, -1
    j gwen_throw_loop
    
end_gwen_throw:
    # 3) Reset her holding data
    sb $s1, 1($s0)
    bne $s1, $zero, throw_done
    addi $t0, $zero, BOMB_EMPTY
    sb $t0, 0($s0)
throw_done:
    pop($s4)
    pop($s3)
    pop($s2)
    pop($s1)
    pop($s0)
    pop($ra)
    jr $ra