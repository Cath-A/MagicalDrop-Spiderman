################# CSC258 Assembly Final Project ###################
# All drawing data (sprites, palettes, rectangle lists) and drawing code.
##############################################################################
.include "macros.asm"
    .data
##############################################################################
# Palettes: one word per colour (0x00RRGGBB).
# Index 0 is never read: in a sprite, index 0 means "transparent".
##############################################################################
# gwen: pink, white, black, dark pink, blue
gwen_palette:   
    .word 0x00000000, 0x00CD2966, 0x00FFFFFF, 0x00000000, 0x00991C47, 0x000A9693
# bombs: transparent, outline, main, shade, shine
bomb_orange:    .word 0x00000000, 0x007A3410, 0x00F28C28, 0x00C9641A, 0x00FFFFFF
bomb_green:     .word 0x00000000, 0x001F4D2B, 0x006CC24A, 0x003E9142, 0x00FFFFFF
bomb_yellow:    .word 0x00000000, 0x008A5A12, 0x00FFD23F, 0x00E0A526, 0x00FFFFFF
bomb_brown:     .word 0x00000000, 0x003F2314, 0x00A0673C, 0x007A4A2A, 0x00FFFFFF
# bomb colour index 0..3 -> palette address
bomb_palettes:  .word bomb_orange, bomb_green, bomb_yellow, bomb_brown
bomb_hidden:   
    .word 0x00000000, 0x00464646, 0x00B4B4B4, 0x007a797a, 0x00FFFFFF
hidden_palette:
    .word bomb_hidden, bomb_hidden, bomb_hidden, bomb_hidden

##############################################################################
# Sprites: word width, word height, then one byte per pixel (palette index).
##############################################################################
gwen_sprite:
    .word 11, 15
    .byte 0,0,0,1,1,1,1,1,0,0,0
    .byte 0,0,1,2,2,2,2,2,1,0,0
    .byte 0,1,2,2,2,2,2,2,2,1,0
    .byte 0,1,1,2,2,2,2,2,1,1,0
    .byte 0,1,2,1,2,2,2,1,2,1,0
    .byte 0,1,2,2,1,2,1,2,2,1,0
    .byte 0,1,2,2,1,2,1,2,2,1,0
    .byte 0,0,1,1,2,2,2,1,1,0,0
    .byte 0,1,2,1,1,1,1,1,2,1,0
    .byte 1,2,2,3,2,2,2,3,2,2,1
    .byte 1,4,1,3,3,2,3,3,1,4,1
    .byte 0,1,1,3,3,3,3,3,1,1,0
    .byte 0,0,1,3,3,3,3,3,1,0,0
    .byte 0,0,1,5,5,1,5,5,1,0,0
    .byte 0,0,0,1,1,0,1,1,0,0,0
    .align 2

bomb_sprite:
    .word 7, 7
    .byte 0,0,1,1,1,0,0
    .byte 0,1,2,2,2,1,0
    .byte 1,2,2,2,4,2,1
    .byte 1,2,2,2,2,2,1
    .byte 1,3,3,3,3,3,1
    .byte 0,1,3,3,3,1,0
    .byte 0,0,1,1,1,0,0
    .align 2

##############################################################################
# Rectangle lists: (byte offset from $gp, height, width) per rectangle.
# offset = row * 512 + column * 4
##############################################################################
water_colour:   
    .word 0x002A1A4F
water_count:    
    .word 1
water_rect:    
    .word 44544, 9, 128

skyline_colour: 
    .word 0x005A3E8C
skyline_count:  
    .word 30
skyline_rects:
    .word 36352, 16, 2
    .word 33288, 22, 4
    .word 39456, 8, 6
    .word 31288, 24, 8
    .word 30296, 26, 4
    .word 31336, 24, 8
    .word 41608, 4, 6
    .word 26272, 34, 2
    .word 26280, 34, 2
    .word 25264, 36, 4
    .word 39616, 8, 2
    .word 34504, 18, 7
    .word 34540, 20, 3
    .word 40696, 8, 4
    .word 43784, 2, 2
    .word 39696, 10, 2
    .word 38680, 12, 12
    .word 39752, 10, 2
    .word 43856, 2, 2
    .word 39768, 10, 2
    .word 38752, 12, 12
    .word 39824, 10, 2
    .word 43928, 2, 2
    .word 41888, 6, 4
    .word 36784, 16, 4
    .word 35776, 18, 2
    .word 36808, 16, 2
    .word 33744, 22, 2
    .word 36824, 16, 2
    .word 41952, 6, 8

frame_colour:   
    .word 0x00FFF9BD
frame_count:    
    .word 4
frame_rects:
    .word 24, 87, 2
    .word 228, 87, 2
    .word 43552, 2, 49
    .word 3616, 1, 49

##############################################################################
# Code
##############################################################################
    .text

# Draws anything static.
draw_static_screen:
    push($ra)
    
    la $a0, water_rect
    lw $a1, water_count
    lw $a2, water_colour
    jal draw_rect_list
    
    la $a0, skyline_rects
    lw $a1, skyline_count
    lw $a2, skyline_colour
    jal draw_rect_list
    
    la $a0, frame_rects
    lw $a1, frame_count
    lw $a2, frame_colour
    jal draw_rect_list
    
    pop($ra)
    jr $ra

# Draws Gwen sprite.
# Params: a0 = gwen_offset
draw_gwen:
    push($ra)
    add $a0, $gp, $a0
    la $a1, gwen_sprite
    la $a2, gwen_palette
    jal draw_sprite
    pop($ra)
    jr $ra

# Erases Gwen sprite.
# Params: a0 = gwen_offset
erase_gwen:
    push($ra)
    add $a0, $gp, $a0
    addi $a1, $zero, 15
    addi $a2, $zero, 11
    add $a3, $zero, $zero
    jal rectangle
    pop($ra)
    jr $ra

# Draws one bomb.
# Params: a0 = screen address, a1 = colour index (>= NUM_COLOURS draws nothing),
#         a2 = palette table (bomb_palettes, or hidden_palette to hide the colour)
draw_bomb:
    push($ra)
    sltiu $t0, $a1, NUM_COLOURS
    beq $t0, $zero, draw_bomb_done
    sll $t0, $a1, 2
    add $t0, $t0, $a2
    lw $a2, 0($t0)
    la $a1, bomb_sprite
    jal draw_sprite
draw_bomb_done:
    pop($ra)
    jr $ra

# Draws incoming bombs.
# Params: a0 = bombs pointer, a1 = reveal flag (1 to reveal, 0 to hide)
draw_hidden_bombs:
    push($ra)
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    
    add $s0, $a0, $zero         # s0 = bombs pointer
    addi $s1, $zero, GRID_COLS
    addi $s2, $gp, NEXT_ROW_OFFSET
    add $s3, $a1, $zero         # s3 = reveal flag
    
    draw_new_bomb:
        beq $s3, $zero, hide_bomb
        la $a2, bomb_palettes
        j draw_new_bomb_start
        hide_bomb:
            la $a2, hidden_palette        
        draw_new_bomb_start:
            add $a0, $s2, $zero
            lw $a1, 0($s0)
            jal draw_bomb
            addi $s0, $s0, 4
            addi $s2, $s2, 28
            addi $s1, $s1, -1
            bne $s1, $zero, draw_new_bomb
    pop($s3)
    pop($s2)
    pop($s1)
    pop($s0)
    pop($ra)
    jr $ra

# Draws bombs inside the frame
# Params: a0 = start of where the bombs are located
draw_bombs:
    push($ra)
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    push($s4)
    
    add $s0, $a0, $zero         # s0 = grid pointer
    addi $s1, $zero, GRID_ROWS
    addi $s2, $gp, BOMB_OFFSET
    
    grid_row_loop:
        add $s3, $s2, $zero
        addi $s4, $zero, GRID_COLS 
        grid_col_loop:
            add $a0, $s3, $zero
            lw $a1, 0($s0)
            la $a2, bomb_palettes
            jal draw_bomb
            addi $s0, $s0, 4
            addi $s3, $s3, 28
            addi $s4, $s4, -1
            bne $s4, $zero, grid_col_loop
        addi $s2, $s2, 3584
        addi $s1, $s1, -1
        bne $s1, $zero, grid_row_loop
    
    pop($s4)
    pop($s3)
    pop($s2)
    pop($s1)
    pop($s0)
    pop($ra)
    jr $ra

# Draws anything dynamic.
# Params: a0 = reveal, a1 = gwen_offset, a2 = grid_ptr, a3 = new_bombs_ptr
draw_dynamic:
    push($ra)
    push($s0)
    push($s1)
    push($s2)
    push($s3)

    add $s0, $a0, $zero
    add $s1, $a1, $zero
    add $s2, $a2, $zero
    add $s3, $a3, $zero

    # 1. Incoming row
    add $a0, $s3, $zero
    add $a1, $s0, $zero
    jal draw_hidden_bombs

    # 2. Grid
    add $a0, $s2, $zero
    jal draw_bombs

    # 3. Gwen
    add $a0, $s1, $zero
    jal draw_gwen
    
    # 4. Bomb Gwen is holding (in front of her)
    add $a0, $gp, $s1
    addi $a0, $a0, 3080
    la $t0, gwen_hold
    lbu $a1, 0($t0)
    la $a2, bomb_palettes
    jal draw_bomb

    pop($s3)
    pop($s2)
    pop($s1)
    pop($s0)
    pop($ra)
    jr $ra

# Draws a list of rectangles in one colour.
draw_rect_list:
    push($ra)
    push($s0)
    push($s1)
    push($s2)
    
    add $s0, $a0, $zero # list pointer
    add $s1, $a1, $zero # rectangles remaining
    add $s2, $a2, $zero # colour
    beq $s1, $zero, rect_list_done
    
    rect_list_loop:
        lw $a0, 0($s0)
        add $a0, $a0, $gp   # offset -> screen address
        lw $a1, 4($s0)      # height
        lw $a2, 8($s0)      # width
        add $a3, $s2, $zero
        jal rectangle
        
        addi $s0, $s0, 12
        addi $s1, $s1, -1
        bne $s1, $zero, rect_list_loop
        
    rect_list_done:
        pop($s2)
        pop($s1)
        pop($s0)
        pop($ra)
        jr $ra

# Draws a rectangle.
# Params: a0 = offset, a1 = height, a2 = width, a3 = colour
rectangle:
    add $t0, $a0, $zero # row start
    add $t1, $a1, $zero # rows remaining
    
    draw_column:
        beq $t1, $zero, end_column
        add $t2, $t0, $zero         # pixel pointer for this row
        add $t3, $a2, $zero         # pixels remaining in this row
        draw_row:
            beq $t3, $zero, end_row
            sw $a3, 0($t2)
            addi $t2, $t2, 4
            addi $t3, $t3, -1
            j draw_row
        end_row:
            addi $t0, $t0, 512
            addi $t1, $t1, -1
            j draw_column
    end_column:
        jr $ra

# Draws a sprite.
# Params: a0 = offset, a1 = sprite address, a2 = palette address
draw_sprite:
    lw $t0, 0($a1)      # width
    lw $t1, 4($a1)      # rows remaining
    addi $t3, $a1, 8    # pointer to the first pixel byte
    add $t4, $a0, $zero # start of the current row on screen
    
    sprite_column:
        beq $t1, $zero, end_sprite_column
        add $t5, $t4, $zero             # screen pointer for this row
        add $t6, $t0, $zero             # pixels remaining in this row
        
        sprite_row:
            beq $t6, $zero, end_sprite_row
            lbu $t7, 0($t3)             # palette index
            beq $t7, $zero, skip_pixel
            sll $t7, $t7, 2             # index * 4 bytes
            add $t7, $t7, $a2
            lw $t7, 0($t7)              # colour
            sw $t7, 0($t5)
            
            skip_pixel:
                addi $t3, $t3, 1
                addi $t5, $t5, 4
                addi $t6, $t6, -1
                j sprite_row
            
        end_sprite_row:
            addi $t4, $t4, 512
            addi $t1, $t1, -1
            j sprite_column
        
    end_sprite_column:
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
    
    # 1. Calculate Gwen's centre x-coordinate in pixels
    lw $t0, gwen_offset
    andi $t0, $t0, 511      # isolate horizontal byte offset
    srl $t0, $t0, 2         # convert bytes to pixels
    addi $t0, $t0, 5        # Gwen's centre is 5 pixels from left
    
    # 2. Calculate which grid column she's in
    addi $t0, $t0, -8
    bltz $t0, bomb_none
    
    addi $t1, $zero, 7
    divu $t0, $t1
    mflo $s3
    
    sltiu $t1, $s3, GRID_COLS
    beq $t1, $zero, bomb_none
    
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
        
        # Is this cell occupied?
        sltiu $t1, $t0, NUM_COLOURS
        bne $t1, $zero, bomb_found
        
        # Move one row upwards
        addi $s0, $s0, -28
        addi $s1, $s1, -3584
        addi $s2, $s2, -1
        
        bne $s2, $zero, find_bomb_loop
        
    bomb_none:
        addi $v0, $zero, -1
        add $v1, $zero, $zero
        add $a0, $zero, $zero
        j find_bomb_done
    
    bomb_found:
        add $v0, $t0, $zero
        add $v1, $s1, $zero
        add $a0, $s0, $zero
        
    find_bomb_done:
        pop($s3)
        pop($s2)
        pop($s1)
        pop($s0)
        jr $ra