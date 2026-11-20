    .macro push (%reg)
        addi $sp, $sp, -4
        sw %reg, 0($sp)
    .end_macro
    
    .macro pop (%reg)
        lw %reg, 0($sp)
        addi $sp, $sp, 4
    .end_macro