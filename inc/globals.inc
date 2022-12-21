var

gi             : byte;
gp             : ^cardinal;
glass_toggle   : boolean;
glass_blink    : boolean;

se             : byte;
crates         : byte;

lv             : smallint absolute $e7;
key            : char     absolute $e9;
player_x       : byte     absolute $ea;
player_y       : byte     absolute $eb;
bcentr_x       : byte     absolute $ec;
bcentr_y       : byte     absolute $ed;
bsize_x        : byte     absolute $ee;
bsize_y        : byte     absolute $ef;
undo_index     : shortint absolute $f0;

current_screen : byte = SCREEN_BOOT;

secret_keys    : word = 0;

t_pla          : PWord;

move_couter    : word;
move_timer     : byte = 0;
show_timer     : shortint = -1;
odd_frame      : boolean;

toggle_help    : boolean = true;

msx            : TRMT;
msx_on         : boolean = false;
ms             : byte;
msx_toggle     : boolean = true;

f              : file;
ready_to_save  : boolean = false;

screen         : array[0..MAX_Y, 0..MAX_X] of word    absolute SCR_GAME;
lv_pointers    : array[0..HIGH_LEVELS]     of ^word   absolute ADR_LV_POINTERS;
lv_depacked    : array[0..SIZE_MAX_LV-1]   of byte    absolute ADR_DEPACED_LV;
board          : array[0..MAX_Y, 0..MAX_X] of byte    absolute ADR_BOARD;
undo           : array[0..HIGH_UNDO]       of byte    absolute ADR_UNDO;

progress       : array [0..HIGH_PROGRESS]  of byte    absolute ADR_PROGRESS;
complete       : array [0..HIGH_SETS]      of word    absolute ADR_COMPLETE;
progr_se_index : word;

glass          : array[0..31]              of cardinal absolute ADR_GLASS;
glass_empty    : array[0..9]               of cardinal absolute ADR_EMPTY_GLASS;