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
# REMEMBER WHEN GWEN MOVES THE WEB SHOULD BE OVERRITTEN TO ERASE OLD AND DRAW NEW
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
    
    # Update gwen_col
    # 1. Calculate Gwen's centre x-coordinate in pixels
    andi $t4, $t2, 511      # isolate horizontal byte offset
    srl $t4, $t4, 2         # convert bytes to pixels
    addi $t4, $t4, -3
    bltz $t4, gwen_col_outside
    addi $t5, $zero, 7
    divu $t4, $t5
    mflo $t4
    sltiu $t5, $t4, GRID_COLS
    bne $t5, $zero, gwen_col_store
gwen_col_outside: 
    addi $t4, $zero, -1
gwen_col_store:
    sw $t4, gwen_col
move_gwen_done:
    pop($ra)
    jr $ra

# Finds the nearest bomb above Gwen in her current location.
#
# Returns:
#   v0 = index of bomb's colour, -1 if no bomb found
#   v1 = bomb offset
#   a0 = address of bomb's cell in bomb array
find_bomb:
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    
    # 1. Read which grid column she's in
    lw $s3, gwen_col
    bltz $s3, bomb_outside
    
    # 2. Start at the bottom row of the bombs array
    la $s0, bombs
    addi $s0, $s0, 252
    sll $t0, $s3, 2
    add $s0, $s0, $t0
    
    # 3. Calculate the screen offset of that bomb
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

animate_web:

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
    push($s5)
    add $s5, $zero, $zero
    # 1) check if she even has a bombs, if not go to end_gwen_throw
    la $s0, gwen_hold
    lbu $s1, 1($s0)                     # how many bombs she has
    beq $s1, $zero, end_gwen_throw
    lw $t0, gwen_col
    bltz $t0, end_gwen_throw
    jal find_bomb 
    bltz $v0, throw_top_cell
    
    addi $s2, $a0, 28                   # new bomb next location
    add $s4, $gp, $v1
    addi $s4, $s4, 3584                 # new bomb next address
    j throw_set_limit
    
throw_top_cell:
    lw $t2, gwen_col
    la $s2, bombs 
    sll $t0, $t2, 2
    add $s2, $s2, $t0                   # grid: bombs + 4col
    
    addi $t1, $zero, 28
    mult $t2, $t1
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
    add $s5, $s2, $zero
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
    add $v0, $s5, $zero
    pop($s5)
    pop($s4)
    pop($s3)
    pop($s2)
    pop($s1)
    pop($s0)
    pop($ra)
    jr $ra

# Given a grid position, return the row and column in the grid
# a0 = grid position
# v0 = column, v1 = row
get_bomb_row_col:
    la $t0, bombs
    sub $t0, $a0, $t0
    srl $t0, $t0, 2
    addi $t1, $zero, GRID_COLS
    divu $t0, $t1
    mflo $v1
    mfhi $v0
    jr $ra
# Given a bomb's row address, return the address on the screen
# a0 = grid address
# v0 = screen address
get_bomb_address:
    push($ra)
    jal get_bomb_row_col
    # get the offset
    addi $t0, $zero, 28
    mult $v0, $t0
    mflo $v0
    addi $t0, $zero, 3584
    mult $t0, $v1
    mflo $t0
    add $v0, $v0, $t0
    add $v0, $v0, $gp
    addi $v0, $v0, BOMB_OFFSET
    pop($ra)
    jr $ra

# Checks if there's a match 3 from a given grid starting position (bottom up)
# a0 = starting grid position
trigger:
    la $t3, bombs
    addi $t3, $t3, 56
    blt $a0, $t3, trigger_done
    lw $t0, 0($a0)
    sltiu $t3, $t0, NUM_COLOURS
    beq $t3, $zero, trigger_done
    lw $t1, -28($a0)
    lw $t2, -56($a0)
    bne $t0, $t1, trigger_done
    bne $t1, $t2, trigger_done
# Finds all adjacent, same coloured bombs (from bottom up), then calls draw_explosion
# Pre: there is a match 3 
# a0 = starting grid position
flood_fill:
    push($ra)
    push($s0)
    push($s1)
    lw $s0, 0($a0)
    addi $s1, $a0, 0
    # 0) Push wincon onto stack after a short pause for visuals
    li $v0, 32
    li $a0, 255
    syscall
    push($zero)
    push($s1)
    explode_loop:
        pop($s1)
        beq $s1, $zero, end_explosion
        lw $t0, 0($s1)
        bne $t0, $s0, explode_loop
        addi $t0, $zero, BOMB_EMPTY
        sw $t0, 0($s1)
        add $a0, $s1, $zero 
        jal get_bomb_address
        add $a0, $v0, $zero
        addi $a1, $zero, 7                  
        addi $a2, $zero, 7              
        add $a3, $zero, $zero
        jal rectangle
        add $a0, $s1, $zero
        add $a1, $s0, $zero
        jal push_adjacent_bombs
        j explode_loop
end_explosion:
    pop($s1)
    pop($s0)
    pop($ra)
    jr $ra
trigger_done:
    jr $ra
    
    
# Given a grid address a0, push only the same coloured neighbours in boundary 
push_adjacent_bombs:
    add $t9, $ra, $zero
    jal get_bomb_row_col
    add $t1, $a0, $zero
    add $t2, $a1, $zero
left:
    beq $v0, $zero, right
    lw $t3, -4($t1)
    bne $t3, $t2, right
    addi $t6, $t1, -4
    push($t6)
right:
    addi $t0, $zero, GRID_COLS
    addi $t0, $t0, -1
    beq $v0, $t0, up
    lw $t3, 4($t1)
    bne $t3, $t2, up
    addi $t6, $t1, 4
    push($t6)
up:
    beq $v1, $zero, down
    lw $t3, -28($t1)
    bne $t3, $t2, down
    addi $t6, $t1, -28
    push($t6)
down:
    addi $t0, $zero, GRID_ROWS
    addi $t0, $t0, -1
    beq $v1, $t0, end_get_adjacent_bombs
    lw $t3, 28($t1)
    bne $t3, $t2, end_get_adjacent_bombs
    addi $t6, $t1, 28
    push($t6)
end_get_adjacent_bombs:
    jr $t9
    
apply_gravity:
    push($ra)
    push($s0)
    push($s1)
    push($s2)
    
    # Checks to see if it's time to animate gravity
    la $t0, cycles
    lw $t0, 0($t0)
    andi $t0, $t0, 15
    bne $t0, $zero, gravity_done
    
    la $s0, bombs                       # s0 = starting bomb grid address
    addi $s1, $zero, GRID_COLS
    sll $s1, $s1, 2                     # col * 4 = next row offset in grid
    add $s1, $s0, $s1                   # s1 = next row offset + grid address 
    addi $s2, $s0, 280                  # s2 = starting address + length of grid
    
    gravity_loop:
        beq $s1, $s2, gravity_done
        
        # Check if there is a bomb
        lw $t1, 0($s1)
        bge $t1, BOMB_EMPTY, grounded
        # Check if there's a bomb above it
        lw $t0, -28($s1)
        blt $t0, BOMB_EMPTY, grounded
        
        # Move the bomb upwards
        sw $t1, -28($s1)
        addi $t2, $zero, BOMB_EMPTY
        sw $t2, 0($s1)
        
        addi $a0, $s1, -28
        jal get_bomb_address
        add $a0, $v0, $zero
        lw $a1, -28($s1)
        jal draw_bomb
        
        # Erase
        add $a0, $s1, $zero
        jal get_bomb_address    
        add $a0, $v0, $zero
        addi $a1, $zero, 7                  
        addi $a2, $zero, 7              
        add $a3, $zero, $zero
        jal rectangle
        
        addi $t2, $zero, BOMB_EMPTY
        sw $t2, 0($s1)
    grounded:
        addi $s1, $s1, 4 
        j gravity_loop
        
gravity_done:
    pop($s2)
    pop($s1)
    pop($s0)
    pop($ra)
    jr $ra