################# CSC258 Assembly Final Project ###################
# All drawing data (sprites, palettes, rectangle lists) and drawing code.
##############################################################################
.include "macros.asm"
    .data
##############################################################################
# Palettes: one word per colour (0x00RRGGBB).
# Index 0 is never read: in a sprite, index 0 means "transparent".
##############################################################################
# gwen: transparent, pink, white, black, dark pink, blue
gwen_palette:
    .word 0x00000000, 0x00CD2966, 0x00FFFFFF, 0x00000000, 0x00991C47, 0x000A9693
green_goblin_palette:
# green goblin: 0: transparent, 1: outline (unused), 2: purple, 3: dark purple, 4: green, 5: yellow, 6: white, 7: light gray, 8: dark gray, 9: darkest (outline)
    .word 0x00000000, 0x00000000, 0x00A64FD6, 0x006E2E9E, 0x006CC24A, 0x00FFD23F, 0x00FFFFFF, 0x00B8B2C8, 0x007D7692, 0x001A0F2E
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
    
green_goblin:
    .word 35, 30
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,9,9,9,9,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,9,2,2,2,2,2,2,2,2,9,9,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,9,2,2,2,2,2,2,2,2,2,2,2,9,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,9,2,2,2,2,2,2,2,2,2,2,9,2,2,9,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,9,2,2,2,2,2,2,2,2,2,9,4,9,2,2,9,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,9,4,2,2,2,4,4,4,2,2,9,4,9,9,2,9,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,9,9,4,2,4,9,9,4,4,2,4,4,9,0,9,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,9,5,9,4,9,0,5,4,4,2,4,4,9,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,9,5,0,4,0,0,5,4,4,2,4,9,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,9,4,5,4,5,5,4,6,4,4,9,0,0,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,9,9,4,6,6,6,6,4,4,9,9,9,9,0,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,9,4,4,9,6,6,6,4,4,9,2,2,4,4,9,0,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,4,4,4,2,9,9,9,9,9,2,2,2,4,4,4,9,0,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,4,4,4,9,2,9,3,9,2,2,2,9,4,4,4,4,9,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,4,4,4,4,9,2,2,9,3,9,2,2,9,9,4,4,4,9,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,9,0,0,0,2,4,4,4,9,9,2,2,2,9,3,9,9,9,9,2,2,2,9,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,9,9,9,9,9,9,0,9,2,2,2,2,9,3,3,3,9,2,2,2,9,0,0,0,0,0,0,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,0,0,0,9,2,2,2,2,9,3,3,3,9,2,2,2,9,0,0,0,0,0,0,0,0
    .byte 0,0,9,9,0,0,0,0,0,0,0,0,0,9,3,3,3,3,3,9,9,9,0,9,9,9,0,0,0,0,0,9,9,0,0
    .byte 0,9,7,9,0,0,0,0,0,0,0,0,9,4,2,2,2,2,2,2,2,4,9,0,0,0,0,0,0,0,0,9,7,9,0
    .byte 9,8,7,9,9,9,9,9,9,9,9,9,4,4,4,2,2,9,2,2,4,4,4,9,9,9,9,9,9,9,9,9,7,8,9
    .byte 9,8,7,9,7,7,7,7,9,7,9,2,2,4,4,4,9,0,9,4,4,4,2,2,9,7,9,7,7,7,7,9,7,8,9
    .byte 9,8,7,9,8,8,8,9,2,9,7,2,2,2,2,9,0,0,0,9,2,2,2,2,7,9,2,9,8,8,8,9,7,8,9
    .byte 9,7,9,9,8,8,8,9,2,2,7,2,2,2,2,9,9,0,9,9,2,2,2,2,7,2,2,9,8,8,8,9,9,7,9
    .byte 9,7,9,0,9,8,8,9,9,9,9,9,9,9,9,9,8,9,8,9,9,9,9,9,9,9,9,9,8,8,9,0,9,7,9
    .byte 9,7,9,0,0,9,8,8,8,8,8,8,8,7,9,8,8,8,8,8,9,7,8,8,8,8,8,8,8,9,0,0,9,7,9
    .byte 9,7,9,0,0,0,9,7,8,8,8,8,8,8,7,9,8,8,8,9,7,8,8,8,8,8,8,7,9,0,0,0,9,7,9
    .byte 0,9,7,9,0,0,0,7,9,9,7,8,8,8,9,9,8,8,8,9,9,8,8,8,7,9,9,7,0,0,0,9,7,9,0
    .byte 0,0,9,9,0,0,0,7,0,0,7,9,9,9,0,0,9,8,9,0,0,9,9,9,7,0,0,7,0,0,0,9,9,0,0
    .byte 0,0,0,0,0,0,0,0,0,0,7,0,0,0,0,0,0,9,0,0,0,0,0,0,7,0,0,0,0,0,0,0,0,0,0
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
draw_gwen:
    push($ra)
    lw $a0, gwen_offset
    add $a0, $gp, $a0
    la $a1, gwen_sprite
    la $a2, gwen_palette
    jal draw_sprite
    pop($ra)
    jr $ra

# Erases Gwen sprite.
erase_gwen:
    push($ra)
    lw $a0, gwen_prev_offset
    add $a0, $gp, $a0
    addi $a1, $zero, 15
    addi $a2, $zero, 11
    add $a3, $zero, $zero
    jal rectangle
    pop($ra)
    jr $ra

# Draws Green Goblin sprite.
draw_green_goblin:
    push($ra)
    lw $a0, goblin_offset
    add $a0, $gp, $a0
    la $a1, green_goblin
    la $a2, green_goblin_palette
    jal draw_sprite
    
    lw $a0, goblin_offset
    add $a0, $gp, $a0
    addi $a0, $a0, GOBLIN_BOMB_OFFSET
    lw $a1, goblin_bomb_colour
    jal draw_bomb
    
    pop($ra)
    jr $ra

# Erases Green Goblin sprite.
erase_green_goblin:
    push($ra)
    lw $a0, goblin_prev_offset
    add $a0, $gp, $a0
    addi $a1, $zero, 30
    addi $a2, $zero, 35
    add $a3, $zero, $zero
    jal rectangle
    pop($ra)
    jr $ra

# Returns: v0 = starting address, v1 = height from gwen's head
# Returns: v0 = starting address, v1 = height from gwen's head, a0 = cap address (0 = no bomb above her)
web_measurements:
    push($ra)
    jal find_bomb
    add $a0, $zero, $zero               
    bltz $v0, web_empty_column
    srl $t0, $v1, 9
    addi $t0, $t0, 7                    # row just below the bomb
    lw $t3, gwen_col                    # CHANGED: cap position comes from the column, not her offset
    sll $t4, $t3, 3
    sub $t4, $t4, $t3                   # col * 7
    addi $t4, $t4, 10                   # + 8 (grid left edge) + 2 (first of the middle 3 pixels)
    sll $t4, $t4, 2                     # pixels -> bytes
    sll $t5, $t0, 9                     # row * 512
    add $a0, $t5, $t4
    add $a0, $a0, $gp                   # cap screen address
    j web_measure
web_empty_column:
    addi $t0, $zero, 8
web_measure:
    lw $t1, gwen_offset
    srl $t2, $t1, 9
    sub $v1, $t2, $t0
    andi $t1, $t1, 511
    addi $t1, $t1, 20
    sll $t0, $t0, 9
    add $v0, $t0, $t1
    add $v0, $v0, $gp
    pop($ra)
    jr $ra

draw_web:
    push($ra)
    jal web_measurements
    sw $v0, web_addr
    sw $v1, web_height
    sw $a0, web_cap_addr                # remember the cap for erasing
    beq $a0, $zero, web_no_cap          # no bomb above her, so no cap
    addi $a1, $zero, 1                  # 1 tall
    addi $a2, $zero, 3                  # 3 wide
    li $a3, 0x00FFFFFF
    jal rectangle                       # only clobbers t0-t3 and keeps v0/v1
web_no_cap:
    blez $v1, draw_web_done

    sll $t0, $v1, 9                     # start at the bottom of the web (just above her head)
    addi $t0, $t0, -512                 # last row = start + (height - 1) * 512
    add $t0, $v0, $t0
    add $t1, $v1, $zero                 # rows left
    add $t2, $zero, $zero               # phase within the dash + gap cycle
    li $t3, 0x00FFFFFF
    li $t4, WEB_DASH
    addi $t5, $t4, WEB_GAP              # cycle length

web_dash_loop:
    bge $t2, $t4, web_dash_skip         # phase >= DASH means this row is a gap
    sw $t3, 0($t0)
web_dash_skip:
    addi $t2, $t2, 1
    bne $t2, $t5, web_dash_nowrap
    add $t2, $zero, $zero               # wrap to the start of the next dash
web_dash_nowrap:
    addi $t0, $t0, -512                 # move up one row
    addi $t1, $t1, -1
    bgtz $t1, web_dash_loop

draw_web_done:
    pop($ra)
    jr $ra

erase_web:
    push($ra)
    lw $a1, web_height
    beq $a1, $zero, erase_web_done
    lw $a0, web_addr
    addi $a2, $zero, 1
    add $a3, $zero, $zero
    jal rectangle
    lw $a0, web_cap_addr
    beq $a0, $zero, erase_no_cap
    addi $a1, $zero, 1
    addi $a2, $zero, 3
    add $a3, $zero, $zero
    jal rectangle
erase_no_cap:
    sw $zero, web_height
    sw $zero, web_cap_addr
    lw $t0, web_visible
    push($t0)
    sw $zero, web_visible
    jal refresh_screen
    pop($t0)
    sw $t0, web_visible
erase_web_done:
    pop($ra)
    jr $ra

# Draws a bomb.
# Params: a0 = its address, a1 = its colour
draw_bomb:
    la $a2, bomb_palettes
    j draw_bomb_colours
draw_hidden_bomb:
    la $a2, hidden_palette
draw_bomb_colours:
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
# Params: a1 = reveal flag (1 to reveal, 0 to hide)
draw_hidden_bombs:
    push($ra)
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    
    la $s0, new_bombs
    addi $s1, $zero, GRID_COLS
    addi $s2, $gp, NEXT_ROW_OFFSET
    add $s3, $a0, $zero         # s3 = reveal flag
    
    draw_new_bomb:
        add $a0, $s2, $zero
        lw $a1, 0($s0)
        beq $s3, $zero, hide_bomb
        jal draw_bomb
        j new_bomb_next
        hide_bomb:
            jal draw_hidden_bomb      
        new_bomb_next:
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
draw_bombs:
    push($ra)
    push($s0)
    push($s1)
    push($s2)
    push($s3)
    push($s4)
    
    la $s0, bombs
    addi $s1, $zero, GRID_ROWS
    addi $s2, $gp, BOMB_OFFSET
    
    grid_row_loop:
        add $s3, $s2, $zero
        addi $s4, $zero, GRID_COLS 
        grid_col_loop:
            add $a0, $s3, $zero
            lw $a1, 0($s0)
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
# Params: a0 = reveal
draw_dynamic:
    push($ra)
    push($s0)
    
    add $s0, $a0, $zero
    
    # 1. Incoming row
    add $a0, $s0, $zero
    jal draw_hidden_bombs
    
    jal draw_gwen
    jal draw_bombs
    
    # 4. Bomb Gwen is holding (in front of her)
    lw $t0, gwen_offset
    add $a0, $gp, $t0
    addi $a0, $a0, 3080
    la $t0, gwen_hold
    lbu $a1, 0($t0)
    jal draw_bomb
    
    lw $t0, web_visible                 # CHANGED: web goes on top of everything else
    beq $t0, $zero, draw_dynamic_done
    jal draw_web

draw_dynamic_done:
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