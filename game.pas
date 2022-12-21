program ProHiBan;

//==============================================================================

{$define basicoff}
{$define romoff}

//==============================================================================

uses atari, crt, cio, aplib, rmt, joystick;

//==============================================================================

{$i inc/const.inc}
{$i inc/data.inc}

//------------------------------------------------------------------------------

{$i inc/registers.inc}
{$i inc/globals.inc}

//==============================================================================

procedure lv_erase_line;
begin
  move(pointer(LAST_LINE_TMP), pointer(LAST_LINE), SIZE_ROW - 2);
end;

//==============================================================================

procedure cursor_tile_hack; inline;
begin
  if (COLCRS and 1) = 0 then OLDCHR := lo(T_GRA) else OLDCHR := hi(T_GRA);
end;

//==============================================================================

procedure set_stack; assembler; inline;
asm
  stx $ff
  ldx #$ff
  txs
  ldx $ff
end;

//==============================================================================

procedure screen_on; inline;
begin
  SDMCTL := ANTIC_ON;
end;

//------------------------------------------------------------------------------

procedure screen_off; inline;
begin
  SDMCTL := ANTIC_OFF
end;

//==============================================================================

procedure glass_off; inline;
begin
  glass_toggle := false;
  pause;
end;

//------------------------------------------------------------------------------

procedure glass_on;
var
  prev_scr   : byte absolute $ff;
  percentage : smallint absolute $fe;
begin
  screen_off;

  pause;

  prev_scr       := current_screen;
  current_screen := SCREEN_GLASS;  

  COLOR0 := G_COLOR0;
  COLOR1 := G_COLOR1;
  COLOR2 := G_COLOR2;
  COLOR4 := G_COLOR4;
  SDLSTL := word(@DL_GLASS);
  SAVMSC := SCR_GLASS;

  clrscr;

  gp := pointer(SCR_GLASS + 14);
  for gi := 0 to GLASS_ROWS-1 do begin
    gp^ := glass[gi]; inc(gp, 8);
  end;

  if prev_scr <> SCREEN_BOOT then
  begin
    percentage := 9 - byte(round((complete[se] * 10) / (SETS_SIZE[se] + 1)));
    if percentage > 0 then begin
      gp := pointer(SCR_GLASS + 14 + (6 * SIZE_GLASS_ROW));
      for gi := 0 to percentage do begin
        gp^ := glass_empty[gi]; inc(gp, 8);
      end;    
    end;   
  end;

  glass_toggle := true;
  glass_blink  := true;

  pause;
  SDMCTL := ANTIC_ON_NARROW;
end;

//==============================================================================

procedure sfx_move; inline;
begin
  msx.sfx(0,0,0);
end;

//------------------------------------------------------------------------------

procedure sfx_push; inline;
begin
  msx.sfx(1,0,0);
end;

//------------------------------------------------------------------------------

procedure sfx_win; inline;
begin
  msx.sfx(2,0,0);
end;

//==============================================================================

procedure music_off;
begin
  msx.stop;
  NoSound;
  msx_on := false; 
end;

//------------------------------------------------------------------------------

procedure music_on(l: boolean); register;
begin
  if l then begin
    if current_screen = SCREEN_GAME then begin
      cursor_tile_hack; GotoXY(0,14); write('LOADING MUSIC'#31);
    end;

    unapl(modules[ms], pointer(RMT_MUSIC));

    if current_screen = SCREEN_GAME then lv_erase_line;
  end;

  msx.init(0);
  msx_on := true;
  msx_toggle := true;
end;

//------------------------------------------------------------------------------

procedure music_next;
begin
  music_off;
  if ms < HIGH_MODULES then inc(ms) else ms := 0;
  music_on(true);
end;

//------------------------------------------------------------------------------

procedure music_prev;
begin
  music_off;
  if ms > 0 then dec(ms) else ms := HIGH_MODULES;
  music_on(true);
end;

//==============================================================================

procedure progress_load;
begin
  assign(f, D_PROGRESS);
  reset(f, 1);
  BlockRead(f, progress, SIZE_PROGRESS_F);
  close(f);
end;

//------------------------------------------------------------------------------

procedure progress_save;
var
  i        : word absolute $fe;
begin
  if ready_to_save = true then begin
    if current_screen <> SCREEN_DELETE then begin
      GotoXY(0,14); write('SAVING PROGRESS');
    end;

    music_off;

    assign(f, D_PROGRESS);
    rewrite(f, 1);
    for i := 0 to (SIZE_PROGRESS_F - 1) do BlockWrite(f, progress[i], 1);
    close(f);

    ready_to_save := false;

    music_on(false);
  end;
end;

//==============================================================================

procedure screen_set; inline;
begin
  SDLSTL := word(@DL_MAIN);
  SAVMSC := SCR_GAME;
end;

//------------------------------------------------------------------------------

procedure colors_set;
begin
  COLOR0 := S_COLOR0; 
  COLOR1 := S_COLOR1; 
  COLOR2 := S_COLOR2; 
  COLOR3 := S_COLOR3; 
  COLOR4 := S_COLOR4;
end;

//------------------------------------------------------------------------------

procedure colors_rnd_set;
var
  r : byte absolute $ff;  
begin
  r := random(7);

  COLOR0 := colors[r,0];
  COLOR1 := colors[r,1];
  COLOR2 := colors[r,2];
  COLOR3 := colors[r,3];
  COLOR4 := colors[r,4]; 
end;

//------------------------------------------------------------------------------

procedure screen_fill(lms, tile: word); register;
var
  i : byte absolute $ff;
begin
  for i := (SIZE_SCREEN shr 3 - 1) downto 0 do begin
    dPoke(lms + (SIZE_SCREEN shr 2 * 0), tile);
    dPoke(lms + (SIZE_SCREEN shr 2 * 1), tile);
    dPoke(lms + (SIZE_SCREEN shr 2 * 2), tile);
    dPoke(lms + (SIZE_SCREEN shr 2 * 3), tile);
    inc(lms, 2);
  end;
end;

//------------------------------------------------------------------------------

procedure screen_put;
var
  x      : byte absolute $ff; //shared vars #1
  y      : byte absolute $fe; //shared vars #1
  tile   : word absolute $fc;
begin
  case board[y,x] of
    B_WAL        : tile := T_WAL;
    B_FLO        : tile := T_FLO;
    B_CRA        : tile := T_CRA;
    B_CRD        : tile := T_CRD;
    B_DEC        : tile := T_DEC;
    B_GRA        : tile := T_GRA;
    B_PLA, B_PLD : tile := t_pla^;
  end;

  screen[bcentr_y + y, bcentr_x + x] := tile;
end;

//------------------------------------------------------------------------------

procedure screen_update;
var      //shared vars #1
  x      : byte absolute $ff;
  y      : byte absolute $fe;
begin
  for y := (player_y - 1) to (player_y + 1) do
    for x := (player_x - 1) to (player_x + 1) do
      screen_put;
end;

//------------------------------------------------------------------------------

procedure screen_draw;
var      //shared vars #1
  x      : byte absolute $ff;
  y      : byte absolute $fe;
begin
  for y := 0 to bsize_y do
    for x := 0 to bsize_x do
      screen_put;
end;

//==============================================================================

procedure move_make(joy: byte);
var
  update              : boolean absolute $ff;
  x                   : byte    absolute $fe;
  y                   : byte    absolute $fd;
  i                   : byte    absolute $fc;
  undo_m              : byte    absolute $fb;
  step0               : PByte;
  step1               : PByte;
  step2               : PByte;
begin
  ATRACT := 0;
  update := false;

  x := player_x;
  y := player_y;
  step0 := @board[y,x];

  undo_m := step0^ or joy;

  case joy of
    joy_right: begin
      step1 := step0 + 1;
      step2 := step1 + 1;
      inc(x);
      t_pla^ := T_PLA_RIGHT;
    end;
    joy_left: begin
      step1 := step0 - 1;
      step2 := step1 - 1;
      dec(x);
      t_pla^ := T_PLA_LEFT;
    end;
    joy_up: begin
      step1 := step0 - (MAX_X + 1);
      step2 := step1 - (MAX_X + 1);
      dec(y);
      t_pla^ := T_PLA_UP;
    end;
    joy_down: begin
      step1 := step0 + (MAX_X + 1);
      step2 := step1 + (MAX_X + 1);
      inc(y);
      t_pla^ := T_PLA_DOWN;
    end;
  end;

  if step1^ = B_FLO then
  begin
    step1^ := B_PLA; update := true;
  end else

  if step1^ = B_DEC then
  begin
    step1^ := B_PLD; update := true;
  end else

  if ((step1^ = B_CRA) or (step1^ = B_CRD)) and ((step2^ = B_FLO) or (step2^ = B_DEC)) then
  begin
    undo_m := undo_m or %00010000;

    if step2^ = B_FLO then step2^ := B_CRA else step2^ := B_CRD;

    if (step1^ = B_CRA) and (step2^ = B_CRD) then dec(crates) else
    if (step1^ = B_CRD) and (step2^ = B_CRA) then inc(crates);

    if step1^ = B_CRA then step1^ := B_PLA else step1^ := B_PLD;

    update := true;
  end;

  if update then begin

    if undo_index < HIGH_UNDO then
      inc(undo_index)
    else
      for i := 0 to (HIGH_UNDO - 1) do undo[i] := undo[i+1];
    if undo_index >= 0 then undo[undo_index] := undo_m;

    if step0^ = B_PLA then step0^ := B_FLO else step0^ := B_DEC;

    player_x := x;
    player_y := y;

    if odd_frame then inc(t_pla^, $0202);
    odd_frame := not odd_frame;

    move_timer := JOY_DELAY;

    inc(move_couter); if not msx_toggle then sfx_move;

    screen_update;
  end;

end;

//------------------------------------------------------------------------------

procedure move_undo;
var
  joy                 : byte absolute $fb;
  moved               : byte absolute $fa;
  pla                 : byte absolute $f9;
  x                   : byte absolute $f8;
  y                   : byte absolute $f7;
  step0               : PByte;
  step1               : PByte;
begin
  if undo_index >= 0 then begin
    x := undo[undo_index];
    dec(undo_index);

    joy   := x and %00001111;
    moved := x and %00010000;
    pla   := x and %11100000;

    x := player_x;
    y := player_y;
    step0 := @board[y,x];

    if step0^ = B_PLD then step0^ := B_DEC else step0^ := B_FLO;

    case joy of
      joy_right: begin
        dec(x);
        step1 := step0 + 1;
        t_pla^ := T_PLA_RIGHT;
      end;
      joy_left: begin
        inc(x);
        step1 := step0 - 1;
        t_pla^ := T_PLA_LEFT;
      end;
      joy_up: begin
        inc(y);
        step1 := step0 - (MAX_X + 1);
        t_pla^ := T_PLA_UP;
      end;
      joy_down: begin
        dec(y);
        step1 := step0 + (MAX_X + 1);
        t_pla^ := T_PLA_DOWN;
      end;
    end;

    if moved <> 0 then begin
      if step0^ = B_DEC then begin
        step0^ := B_CRD;
        dec(crates);
      end else
        step0^ := B_CRA;

      if step1^ = B_CRD then begin
        step1^ := B_DEC;
        inc(crates);
      end else
        step1^ := B_FLO;
    end;

    screen_update;

    board[y,x] := pla;
    player_x := x;
    player_y := y;

    if odd_frame then inc(t_pla^, $0202);
    odd_frame := not odd_frame;

    screen[bcentr_y + y, bcentr_x + x] := t_pla^;
  end;
end;

//==============================================================================

procedure lv_depack;
var
  i        : byte absolute $ff;
  ii       : word absolute $fd;
  r        : byte absolute $fc;
  t        : byte absolute $fb;
  rr       : byte absolute $fa;
  lv_end   : byte absolute $f9;
  tmp      : PByte;
begin
  tmp := lv_pointers[lv];

  lv_end := tmp^;
  inc(tmp, 3);

  ii := 0;
  for i := 0 to lv_end do begin
    rr := tmp^ and %00011111;
    t  := tmp^ and %11100000;

    for r := 1 to rr do begin
      lv_depacked[ii] := t; inc(ii);
    end;

    inc(tmp);
  end;
end;

//------------------------------------------------------------------------------

procedure board_set;
var
  x        : byte absolute $ff;
  y        : byte absolute $fe;
  b        : byte absolute $fd;
  tmp      : PByte;
begin
  crates := 0;

  tmp := lv_depacked;
  for y := 0 to bsize_y do begin
    for x := 0 to bsize_x do begin
      b := tmp^; inc(tmp);

      if (b = B_PLA) or (b = B_PLD) then begin
        player_x := x;
        player_y := y;
      end;

      if b = B_CRA then inc(crates);

      board[y,x] := b;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure lv_get;
var
  tmp      : PByte;
begin
  lv_depack;

  tmp := lv_pointers[lv];

  bsize_x  := tmp[1] - 1;
  bsize_y  := tmp[2] - 1;

  bcentr_x := (MAX_X - bsize_x) shr 1;
  bcentr_y := (MAX_Y - bsize_y) shr 1;

  board_set;
end;

//==============================================================================

procedure show_select;
var
  i        : byte absolute $ff;
  ii       : byte absolute $fe;
  y        : byte absolute $fd;
  j        : byte absolute $fc;
  letter1  : char absolute $fb;
  letter2  : char absolute $fa;  
  se_name1 : string;
  se_name2 : string;  
begin
  progress_save;

  current_screen := SCREEN_SELECT;
  screen_off; pause; screen_set; colors_set; clrscr;

  letter1 := 'A';
  letter2 := 'M';

  GotoXY(11,1); Write('CHOOSE YOUR POISON '#134#135);

  for i := 0 to 11 do begin
    y := i + 3;
    j := i + 12;

    se_name1 := SETS_NAME[i];
    se_name2 := SETS_NAME[j];

    GotoXY(2,y);  write(complete[i], '/', SETS_SIZE[i] + 1);
    GotoXY(9,y);  write(letter1, '. '); for ii := 3 to (byte(se_name1[0]) - 4) do write(se_name1[ii]);
    GotoXY(21,y); write(complete[j], '/', SETS_SIZE[j] + 1);
    GotoXY(29,y); write(letter2, '. '); for ii := 3 to (byte(se_name2[0]) - 4) do write(se_name2[ii]);

    inc(letter1);
    inc(letter2); 
  end;

  screen_on;
end;

//------------------------------------------------------------------------------

{
procedure show_help;
begin
  progress_save;

  current_screen := SCREEN_HELP;
  show_init;

  GotoXY(12,1); write(#146#147' HELP SCREEN ');
  if toggle_help then begin
    write('1/2'); GotoXY(3,3);
    write(
      #31#31'START            - TITLE SCREEN'#155,
      #31#31'SELECT           - HOME SCREEN'#155,
      #31#31'HELP             - HELP SCREEN'#155,
      #31#31'OPTION           - TOGGLE MUSIC'#155,
      #31#31'STR + OPT + SEL  - RESET PROGRESS'#155,       
      #31#31'KEY RIGHT        - NEXT LEVEL'#155,
      #31#31'KEY LEFT         - PREV LEVEL'#155,
      #31#31'KEY UP           - NEXT 10 LEVELS'#155,
      #31#31'KEY DOWN         - PREV 10 LEVELS'#155,
      #31#31'A ... X          - CHOOSE SET'
    );
  end else begin
    write('2/2'); GotoXY(3,3);
    writeln(
      #31#31'JOYSTICK         - MOVE PLAYER'#155,
      #31#31'FIRE + UP        - NEXT LEVEL'#155,
      #31#31'FIRE + DOWN      - PREV LEVEL'#155,
      #31#31'FIRE + RIGHT     - RESET LEVEL'#155,
      #31#31'FIRE + LEFT      - TAKE BACK'#155,
      #31#31'SPACE            - RESET LEVEL'#155,      
      #31#31'< OR >           - CHANGE MUSIC'#155,
      #31#31'Z                - FIRST FREE'#155,
      #31#31'SHIFT + Z        - NEXT FREE'#155,
      #31#31'ESC              - WRITE PROGRESS'
    );  
  end; 

  GotoXY(7,14); write('PRESS HELP TO FLIP THIS PAGE');

  toggle_help :=  not toggle_help;

  screen_on;
end;

}

//------------------------------------------------------------------------------

procedure show_help;
begin
  progress_save;

  current_screen := SCREEN_HELP;
  pause; screen_set; colors_set;

  if toggle_help then begin
    move(pointer(SCR_HELP1), pointer(SCR_GAME), SIZE_SCREEN);
  end else begin
    move(pointer(SCR_HELP2), pointer(SCR_GAME), SIZE_SCREEN);
  end;

  toggle_help :=  not toggle_help;
end;

//------------------------------------------------------------------------------

procedure lv_write_number;
var
  i        : byte absolute $ff;
  se_name  : string;
begin
  se_name := SETS_NAME[se];
  move(pointer(LAST_LINE), pointer(LAST_LINE_TMP), SIZE_ROW - 2);

  cursor_tile_hack; GotoXY(0,14);
  write(lv + 1, '/', SETS_SIZE[se] + 1, ' ');
  for i := 3 to (byte(se_name[0]) - 4) do write(se_name[i]); write(#30); // #30 CURSOR LEFT 

  show_timer := SHOW_DURATION;
end;

//------------------------------------------------------------------------------

procedure lv_mark_calc;
var
  i        : word absolute $fe;
  d        : byte absolute $fd;
  r        : byte absolute $fc;
  l        : byte absolute $fb;
begin
  l := 1;
  r := lv mod 8;
  d := lv div 8;
  l := l shl r;
  i := progr_se_index + d;
end;

//------------------------------------------------------------------------------

procedure lv_mark_set;
var
  i        : word absolute $fe;
  l        : byte absolute $fb;
begin
  lv_mark_calc;
  progress[i] := progress[i] or l;
end;

//------------------------------------------------------------------------------

function lv_mark_read: boolean;
var
  i        : word absolute $fe;
  l        : byte absolute $fb;
begin
  lv_mark_calc;
  result := boolean(progress[i] and l);
end;

//------------------------------------------------------------------------------

procedure lv_show;
begin
  current_screen := SCREEN_GAME;

  screen_off;
  pause;

  move_couter := 0;
  undo_index := -1;

  lv_get;

  t_pla^ := T_PLA_LEFT;
  screen_fill(SCR_GAME, T_GRA);
  screen_draw;

  colors_rnd_set;
  screen_set;

  lv_write_number;

  if lv_mark_read then screen[MAX_Y, MAX_X] := T_COM;

  pause; screen_on;
end;

//==============================================================================

procedure lv_reset;
begin
  board_set;
  lv_show;
end;

//------------------------------------------------------------------------------

procedure lv_first_free;
var
  n        : word absolute $fe;
  p        : byte absolute $fd;
  l        : byte absolute $fc;
  r        : byte absolute $fb;
begin
  l := 0;

  for n := progr_se_index to (progr_se_index + (ONE_SET_PROGR - 1)) do if progress[n] <> $ff then break;

  p := progress[n];
  if (p <> 0) then begin
    for l := 0 to 7 do begin
      if (p and 1) = 0 then break;
      p := p shr 1;
    end;
  end;

  n := (n - progr_se_index) * 8 + l;

  if n <= SETS_SIZE[se] then begin
    if lv <> n then begin lv := n; lv_show end;
  end else begin
    if show_timer > 0 then begin show_timer := -1; lv_erase_line end;
    GotoXY(0,14); write('ALL COMPLETED'); write(#30);
    show_timer := SHOW_DURATION;
  end;
end;

//------------------------------------------------------------------------------

procedure lv_next_free;
var
  i        : word absolute $fe;
  n        : word absolute $fc;
  p        : byte absolute $fb;
  l        : byte absolute $fa;
  r        : byte absolute $f9;

begin
  i := progr_se_index + (lv div 8);
  r := (lv mod 8) + 1;

  for n := i to (i + (ONE_SET_PROGR - 1)) do if progress[n] <> $ff then break;

  p := progress[n] shr r;
  for l := r to 7 do begin
    if (p and 1) = 0 then break;
    p := p shr 1;
  end;

  n := (n - progr_se_index) * 8 + l;

  if n <= SETS_SIZE[se] then
    begin lv := n; lv_show end
  else
    lv_first_free;

end;

//------------------------------------------------------------------------------

procedure lv_next(n: byte); register;
begin
  if (lv + n) <= SETS_SIZE[se] then inc(lv, n) else lv := 0;
  lv_show;
end;

//------------------------------------------------------------------------------

procedure lv_prev(n: byte); register;
begin
  if (lv - n) >= 0 then dec(lv, n) else lv := SETS_SIZE[se];
  lv_show;
end;

//------------------------------------------------------------------------------

procedure lv_complete;
begin
  screen[bcentr_y + player_y, bcentr_x + player_x] := T_PLA_WINNER;

  cursor_tile_hack; GotoXY(0,14); write('MOVES:', move_couter,#30);
  if not msx_toggle then sfx_win;

  if not lv_mark_read then begin
    lv_mark_set;
    inc(complete[se]);
    ready_to_save := true;
  end;
  
  pause(SHOW_DURATION);

  lv_next(1);
end;

//==============================================================================

procedure load_set;
var
  i        : word absolute $fe;
  tmp      : Pbyte;
begin
  music_off;

  inc(secret_keys, ord(key));
  if secret_keys = SECRET then move(pointer(ADR_NEW_TILES), pointer(ADR_OLD_TILES), (6*8));

  se := ord(key) - KEY_OFFSET;
  progr_se_index := ONE_SET_PROGR * se;

  glass_on;

  unapl(SETS_NAME[se], pointer(ADR_SET));

  tmp := pointer(ADR_SET);
  for i := 0 to SETS_SIZE[se] do begin
    lv_pointers[i] := tmp;
    inc(tmp, tmp^);
  end;

  glass_off;

  lv := 0; lv_show;

  music_on(false);
end;

//==============================================================================

procedure control_generic;
begin
  case key of
    KEY_ESC        : show_select;
    'a'..'x'       : load_set;
    KEY_MUSIC_NEXT : music_next;
    KEY_MUSIC_PREV : music_prev;    
  end;    
end;

//------------------------------------------------------------------------------

procedure control_help;
begin
    if key = KEY_ESC then show_select;
end;

//------------------------------------------------------------------------------

procedure control_select;
begin
  case key of
    'a'..'x' : load_set;   
  end;
end;

//------------------------------------------------------------------------------

procedure control_game;
begin
  case key of
    KEY_RIGHT      : lv_next(1);
    KEY_LEFT       : lv_prev(1);
    KEY_UP         : lv_next(LV_STEP);
    KEY_DOWN       : lv_prev(LV_STEP);
    KEY_ESC        : show_select;
    KEY_SPACE      : lv_reset;
    'a'..'x'       : load_set;
    'z'            : lv_first_free;
    'Z'            : lv_next_free;
    KEY_MUSIC_NEXT : music_next;
    KEY_MUSIC_PREV : music_prev;
  end;
end;

//==============================================================================

procedure vbk_exit_i; assembler; inline;
asm
  jmp SYSVBV
end;

//------------------------------------------------------------------------------

procedure vbk_exit; assembler; inline;
asm
  jmp XITVBV
end;

//------------------------------------------------------------------------------

procedure vblankd; interrupt;
begin
  if move_timer > 0  then dec(move_timer);
  if show_timer >= 0 then dec(show_timer); 
  if glass_toggle then begin
    if glass_blink then COLOR1 := G_COLOR1 else COLOR1 := G_BLINK;
    glass_blink := not glass_blink;
  end;
  if msx_on then msx.play;  

  vbk_exit;
end;

//==============================================================================

procedure check_consol; inline;
begin
  if consol = CN_OPTION then begin               // F2 atari800 | F4 Altirra | OPTION
    music_off;
    msx_toggle := not msx_toggle;

    if current_screen = SCREEN_GAME then begin
      cursor_tile_hack;
      GotoXY(0,14); write('TOGGLE MUSIC'#31);
    end;

    if msx_toggle then
      unapl(modules[ms], pointer(RMT_MUSIC))
    else
      unapl(D_SFX, pointer(RMT_MUSIC));

    if current_screen = SCREEN_GAME then lv_erase_line;

    msx.init(0);
    msx_on := true;
  end;

  if consol = CN_SELECT then show_select;        // F3 atari800 | F3 Altirra | SELECT

  if consol = CN_START then begin                // F4 atari800 | F2 Altirra | START
    music_off;
    current_screen := SCREEN_BOOT;
    glass_on;
    xio(40,1,0,0,'D:TITLE.XEX'); 
  end;  

  if consol = CN_START_SELECT_OPTION then begin
    current_screen := SCREEN_DELETE;

    pause; colors_set; clrScr;
    GotoXY(10,7); write('PROGRESS IS DELETING');

    FillByte(pointer(ADR_PROGRESS), SIZE_PROGRESS_F, 0);
    ready_to_save := true;
    
    show_select;
  end;

  if HELPFG = KEY_HELP_PRESSED then begin        // F6 atari800 | F6 Altirra | HELP
    HELPFG := 0;
    show_help;
  end;
end;

//------------------------------------------------------------------------------

procedure check_keyboard; inline;
begin
  if keypressed then begin
    key := readkey;
    case current_screen of
      SCREEN_GAME   : control_game;
      SCREEN_SELECT : control_generic;
      SCREEN_HELP   : control_generic;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure check_joy; inline;
begin
  if strig0 <> 0 then begin
    if
      (stick0 = joy_up)   or
      (stick0 = joy_down) or
      (stick0 = joy_left) or
      (stick0 = joy_right)
    then
      move_make(stick0);
  end else begin
    ATRACT := 0;
    case stick0 of
      joy_up    : lv_next(1);
      joy_down  : lv_prev(1);
      joy_left  : move_undo;
      joy_right : lv_reset;
    end;
    if stick0 <> joy_none then move_timer := JOY_DELAY;
  end;
end;

//==============================================================================

procedure init;
begin
  CursorOff;
  Randomize; ms := random(HIGH_MODULES);

  unapl(D_GLASS, pointer(ADR_GLASS));
  glass_on;

  SetIntVec(iVBL, @vblankd);

  progress_load;
  unapl(D_CHARSET, pointer(CHR_MAIN));
  CHBAS := hi(CHR_MAIN);

  unapl(D_HELP, pointer(ADR_TMP));
  move(pointer(ADR_TMP), pointer(SCR_HELP1), SIZE_SCREEN * 2);

  msx.player := pointer(RMT_PLAYER);
  msx.modul  := pointer(RMT_MODUL);
  music_on(true);
  
  glass_off;
end;

//==============================================================================

begin
  set_stack; init;

  show_select; 

  repeat
    pause;

    check_consol;
    check_keyboard;

    if current_screen = SCREEN_GAME then begin
      if show_timer = 0 then lv_erase_line;
      if crates = 0 then lv_complete;
      if move_timer = 0 then check_joy;
    end;

  until false;
end.

//==============================================================================