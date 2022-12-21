; you can use this file to define all your strings in one file 
; it's always useful to do that if you plan to translate your work later

    :384 dta 0
missiles
    :16 dta 0
    :9 dta %00000000
    :10 dta %00001111
    :1  dta %00001110
    :1  dta %00001100
    :10 dta %00111100
    :1  dta %00000000
    :8  dta %11111100
    :3  dta %11111110
    :5  dta %01111110
    :4  dta %01111111
    :16  dta %00000000
    :1  dta %00001000
    :1  dta %00001100
    :2  dta %00000000
    :4  dta %00100011
    :4  dta %00110011
    :6  dta %00000011
    :3  dta %00000001
    
    
    
    .align $80,0
p0
    :16 dta 0
    :31 dta %00011111
    :2  dta %00010100
    :2  dta %11000000
    :4  dta %11100000
    :3  dta %11110000
    :2  dta %11111000
    :2  dta %11111100
    :2  dta %11111110
    :4  dta %11111111
    :14 dta 0
    :14  dta %11111100
    
    .align $80,0
p1
    :20 dta $0
    :48 dta $ff
    :5  dta 0
    :13 dta %11110000
    :14 dta %11111000
    
    .align $80,0
p2
    :16 dta 0
    :32 dta %00011111
    :4  dta 0
    :2  dta %10000000
    :2  dta 0
    
    :2  dta %00000111
    :2  dta %00001111
    :2  dta %00111111
    :9 dta %01111111

    :1  dta 0


   :24  dta %11110000
   

    .align $80,0
p3
    :16 dta 0
    :26 dta %11111100
    :6 dta 0
    :20 dta %00111111
    :4  dta 0


   :25  dta %11111100

    .align $80,0
