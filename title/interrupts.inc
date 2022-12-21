(* declare your interrupt routines here *)

procedure dli;assembler;interrupt;
asm {
    phr ; store registers

    mva #$0 atari.colpf0                 ;---- outline color
    mva #$24 atari.colpf1                ;---- dark color
    mva #$16 atari.colpf2                ;---- face shadow color
    mva adr.letterColors+4 atari.colpf3  ;---- I color
    mva #$12 atari.colbk                 ;---- back color

    mva #$0a atari.colpm1                ;---- hair blink color
    mva adr.letterColors atari.colpm0    ;---- P color
    mva adr.letterColors+1 atari.colpm2  ;---- R color
    mva adr.letterColors+2 atari.colpm3  ;---- O color

    mva #81 hposp1
    mva #111 hposp0
    mva #130 hposp2
    mva #162 hposp3
     
    mva #77 hposm1 
    mva #143 hposm0 
    mva #162 hposm2 
     
    lda #3
    sta sizep0
    sta sizep1
    sta sizep2
    sta sizep3
    lda #%01010101
    sta sizem


@    
    lda #32
    cmp vcount
    bne @- 
    mva #$1a atari.colpm1                ;---- face color

@    
    lda #42
    cmp vcount
    bne @- 
    mva #141 hposp3
    mva adr.letterColors+3 atari.colpm3  ;---- H color


@    
    lda #47
    cmp vcount
    bne @- 
    mva #81 hposp0
    mva #$0a atari.colpm0                ;---- eye top
    lda priorDefault                     ;---- PRORity
    ora #16
    sta $D01B    
    lda #0
    sta sizem
    sta wsync
    mva #175 hposm3
    mva #177 hposm2
    mva #179 hposm1
    mva #181 hposm0
    sta wsync
    mva #$0e atari.colpm0                ;---- eye bottom
    mva #$76 atari.colpm2                ;---- shirt shadow color
    mva #195 hposp2
    sta wsync
    sta wsync
    mva #77 hposp0
    mva #$18 atari.colpm0                ;---- face beard color
    lda #1
    sta sizep0


@    
    lda #52
    cmp vcount
    bne @- 
    mva #$8a atari.colpf2                ;---- shirt color
    sta wsync
    sta wsync
    sta wsync
    sta wsync
    mva #44 hposp2


@    
    lda #71    
    cmp vcount
    bne @- 
    lda priorDefault                     ;---- PRORity
    and #%11101111
    sta $D01B    
    mva #154 hposp1
    mva adr.letterColors+5 colpm1        ;---- B color
    sta wsync
    mva #170 hposp2
    mva adr.letterColors+6 colpm2        ;---- A color
    sta wsync
    mva #182 hposp3
    mva adr.letterColors+7 colpm3        ;---- N color


    mva #170 hposm1
    mva #186 hposm2

    mva #$1a atari.colpm0                ;---- face color
    mva #50 hposp0

    lda #%00000011
    sta sizem

    mva #146 hposm0
    


@    
    lda #86
    cmp vcount
    bne @- 
    mva #$16 atari.colpf2                ;---- barrel top color


    plr                                  ;---- restore registers
};
end;

procedure vbl;assembler;interrupt;
asm {
    pha ; store registers
    

    pla ; restore registers
};
end;
