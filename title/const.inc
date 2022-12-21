//
// ;*** define your project wide constants here

PMG_ADDRESS          = $3c00;
DISPLAY_LIST_ADDRESS = $3b00;
IMAGE_ADDRESS        = $4000;

_P = 0;
_R = 1;
_O = 2;
_H = 3;
_I = 4;
_B = 5;
_A = 6;
_N = 7;

KEY_HELP_PRESSED     = $11;

RMT_MUSIC            = $52e0;
RMT_PLAYER           = $5600;
RMT_MODUL            = $5a00;

DL_CREDITS           = $0980;
SCR_CREDITS          = $1000;

CHR_MAIN             = $0c00;

S_COLOR0             = $8e;
S_COLOR1             = $00;
S_COLOR2             = $8a;
S_COLOR3             = $28;
S_COLOR4             = $94;

MAX_Y                = 13;             // zero indexed
SIZE_ROW             = 40;
SIZE_SCREEN          = (MAX_Y + 1) * SIZE_ROW;
