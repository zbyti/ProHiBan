const

//------------------------------------------------------------------------------

{
  8E5E: 10x 8 BLANK
  8E68: LMS BC00 MODE D
  8E6B: 31x MODE D
  8E8A: JVB 8E5E
}

DL_GLASS : array [0..46] of byte = (
  $70, $70, $70, $70, $70, $70, $70, $70, $70, $70,
  $4D, lo(SCR_GLASS), hi(SCR_GLASS),
  $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D,   
  $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D,
  $41,lo(word(@DL_GLASS)),hi(word(@DL_GLASS))
);

//------------------------------------------------------------------------------

{
  8E8D: 8 BLANK
  8E8E: LMS BC00 MODE 5
  8E91: 13x MODE 5
  8E9E: JVB 8E8D
}

DL_MAIN : array [0..19] of byte = (
  $70,
  $45, lo(SCR_GAME), hi(SCR_GAME),
  $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, $05, 
  $41, lo(word(@DL_MAIN)),hi(word(@DL_MAIN))
);

//------------------------------------------------------------------------------

SETS_NAME : array[0..HIGH_SETS] of string[16] = (
  'D:ABED.APL',     // a
  'D:ARUBA.APL',    // b
  'D:ATLAS.APL',    // c
  'D:BOXXLE.APL',   // d
  'D:COSMAC1.APL',  // e
  'D:COSMAC2.APL',  // f
  'D:COSMOS.APL',   // g
  'D:DUTHEN.APL',   // h
  'D:DZEKIC.APL',   // i
  'D:GARCIA.APL',   // j
  'D:GRIGR.APL',    // k
  'D:HAYWOOD.APL',  // l
  'D:HOLLAND.APL',  // m
  'D:MARQUES.APL',  // n
  'D:MICRO.APL',    // o
  'D:REINKE1.APL',  // p
  'D:REINKE2.APL',  // q
  'D:SASQ.APL',     // r
  'D:SERENA1.APL',  // s
  'D:SERENA2.APL',  // t
  'D:SHARPEN.APL',  // u
  'D:VARIOUS1.APL', // v
  'D:VARIOUS2.APL', // w
  'D:VARIOUS3.APL'  // x
);

//------------------------------------------------------------------------------

SETS_SIZE : array[0..HIGH_SETS] of word = (
  193,              // a
  293,              // b
  60,               // c
  187,              // d
  234,              // e
  171,              // f
  139,              // g
  138,              // h
  127,              // i
  165,              // j
  193,              // k
  178,              // l
  84,               // m
  224,              // n
  395,              // o
  207,              // p
  197,              // q
  234,              // r
  140,              // s
  174,              // t
  80,               // u
  200,              // v
  218,              // w
  176               // x
);

//------------------------------------------------------------------------------

colors : array[0..6, 0..4] of byte = (
  ($fe, $00, $28, $14, $c4),
  ($3c, $00, $16, $54, $92),
  ($fc, $00, $f8, $e2, $14),
  ($2c, $00, $38, $42, $54),
  ($3c, $00, $18, $62, $74),
  ($2c, $00, $28, $a2, $b4),
  ($2e, $00, $2a, $04, $06)
);

//------------------------------------------------------------------------------