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
    
    # 1) check if she even has a bombs, if not go to end_gwen_throw
    
    # 2) now we know she has a bomb... she throws it
    # 3) reset her holding data
    # 4) redraw the screen with the x amount of bombs above her
    # func: gwen_throw_bombs
    
end_gwen_throw:
    pop($ra)
    jr $ra