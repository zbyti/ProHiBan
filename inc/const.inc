const

//==============================================================================

ANTIC_ON         = %00100010;
ANTIC_ON_NARROW  = %00100001;
ANTIC_OFF        = 0;

JOY_DELAY        = 6;
SHOW_DURATION    = 75;

LV_STEP          = 10;

SETVBV           = $E45C;
SYSVBV           = $E45F;
XITVBV           = $E462;

//==============================================================================

SCREEN_GAME      = 0;
SCREEN_SELECT    = 1;
SCREEN_HELP      = 2;
SCREEN_DELETE    = 3;
SCREEN_GLASS     = 4;
SCREEN_BOOT      = 5;

//==============================================================================

KEY_HELP_PRESSED = $11;

KEY_ESC          = chr($1b);
KEY_SPACE        = chr($20);
KEY_RIGHT        = chr($1f);
KEY_LEFT         = chr($1e);
KEY_UP           = chr($1c);
KEY_DOWN         = chr($1d);
KEY_MUSIC_NEXT   = chr($3e);
KEY_MUSIC_PREV   = chr($3c);

KEY_OFFSET       = ord('a');

//==============================================================================

SECRET           = ord('f') + ord('l') + ord('o') + ord('b');

//==============================================================================

S_COLOR0         = $8e;
S_COLOR1         = $00;
S_COLOR2         = $8a;
S_COLOR3         = $28;
S_COLOR4         = $94;

G_COLOR0         = $00;
G_COLOR1         = $8e;
G_COLOR2         = $8a;
G_COLOR4         = $94;
G_BLINK          = $88;

//==============================================================================


B_WAL            = %11100000; // $e0 '#' wall
B_GRA            = %11000000; // $c0 'x' gras
B_PLA            = %10100000; // $a0 '@' player
B_PLD            = %10000000; // $80 '+' player on deck
B_DEC            = %01100000; // $60 '.' deck
B_CRA            = %01000000; // $40 '$' crate
B_CRD            = %00100000; // $20 '*' crate on deck
B_FLO            = %00000000; // $00 ' ' floor

//==============================================================================

T_OFFSET         = $4040;

T_PLA_RIGHT      = T_OFFSET + $0302;
T_PLA_LEFT       = T_OFFSET + $0706;
T_PLA_DOWN       = T_OFFSET + $0b0a;
T_PLA_UP         = T_OFFSET + $0f0e;
T_PLA_WINNER     = T_OFFSET + $1312;

T_INV            = T_OFFSET + $8080;
T_FLO            = T_OFFSET + $0000;
T_CRA            = T_OFFSET + $1514;
T_CRD            = T_OFFSET + T_CRA or T_INV;
T_DEC            = T_OFFSET + $1716;
T_WAL            = T_OFFSET + $1918;
T_GRA            = T_OFFSET + $1b1a or T_INV;
T_COM            = T_OFFSET + $1d1c or T_INV;

//==============================================================================

MAX_Y            = 13;                                      // zero indexed
MAX_X            = 19;                                      // zero indexed

SIZE_ROW         = 40;
SIZE_MAX_LV      = (MAX_X + 1) * (MAX_Y + 1);
SIZE_SCREEN      = (MAX_Y + 1) * SIZE_ROW;

HIGH_LEVELS      = 399;                                     // zero indexed
HIGH_SETS        = 23;                                      // zero indexed
HIGH_UNDO        = 9;                                       // zero indexed, max 31

//==============================================================================
// $0400..$04ff MP buffer
//==============================================================================

ADR_BOARD        = $0500;                                   // $0500..$0617; size $118; SIZE_MAX_LV
ADR_UNDO         = $0618;                                   // $0618..$0627; size $10; size 1-16; MAX_UNDO
ADR_GLASS        = $0628;                                   // $0628..$06A7; size $80
ADR_EMPTY_GLASS  = $06A8;                                   // $06A8..$06CF; size $28
ADR_NEW_TILES    = $06D0;                                   // $06D0..$06FF; size $30

//==============================================================================

ADR_SET          = $0980;                                   // $0980..$52DF (18.784 bytes)

//==============================================================================

ADR_TMP          = $1230;

//==============================================================================

D_SFX            = 'D:SFX.APL';

HIGH_MODULES     = 3;

modules : array[0..HIGH_MODULES] of string[16] = (
  'D:BEETLE.APL',
  'D:FUN.APL',
  'D:FOURTH.APL',
  'D:AXELF.APL'
);

RMT_MUSIC        = $52e0;                                   // $52E0..$7FFF (11.552 bytes)
RMT_PLAYER       = $5600;
RMT_MODUL        = $5a00;

//==============================================================================

D_CHARSET        = 'D:CHARSET.APL';

CHR_MAIN         = $8000;                                   // size $400; 4 pages
ADR_LV_POINTERS  = $8400;                                   // size $320; (HIGH_LEVELS - 1) * 2


ADR_OLD_TILES   = CHR_MAIN + ($58 * 8);

//==============================================================================

D_PROGRESS       = 'D:PROGRESS.SAV';

ADR_PROGRESS     = $8720;                                   // size $4B0; HIGH_PROGRESS + 1
ADR_COMPLETE     = $8BD0;                                   // size $30; (HIGH_SETS + 1) * 2
                                       
ONE_SET_PROGR    = 50;
HIGH_PROGRESS    = ((HIGH_SETS + 1) * ONE_SET_PROGR) - 1;

// 1200 bytes + 48 bytes
SIZE_PROGRESS_F  = (HIGH_PROGRESS + 1) + ((HIGH_SETS + 1) * 2);

//==============================================================================
//MAIN_CODE        = $8C00;              // $8C00..$BBFF ($3000 12288 bytes)
//==============================================================================

D_GLASS          = 'D:GLASS.APL';

//00 ground
//01 black
//10 white
//11 blue

GLASS_ROWS       = 32;
SIZE_GLASS_ROW   = 32;
SIZE_GLASS       = SIZE_GLASS_ROW * GLASS_ROWS; // 1024 [$400] bytes
SCR_GLASS        = $BC00;                       // $BC00..$BFFF

//==============================================================================

SCR_GAME         = $BC00;                                   // $BC00..$BE2F; size $230; SIZE_SCREEN
LAST_LINE_TMP    = $BE30;                                   // $BE30..$BE57; size 40; SIZE_ROW
ADR_DEPACED_LV   = $BE58;                                   // $BE58..$BF6F; size $118; SIZE_MAX_LV
LAST_LINE        = SCR_GAME + (MAX_Y * SIZE_ROW);

//==============================================================================

D_HELP           = 'D:HELP.APL';
SCR_HELP1        = $C000;                                   // $C000..$C22F; size $230; SIZE_SCREEN
SCR_HELP2        = $C230;                                   // $C230..$C45F; size $230; SIZE_SCREEN

//==============================================================================