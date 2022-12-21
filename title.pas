program madStrap;

//==============================================================================

{$define basicoff}
{$librarypath 'blibs'}
{$r title/resources.rc}

//==============================================================================

uses atari, crt, cio, aplib, rmt, b_pmg, b_system, b_crt; // b_utils;

//==============================================================================

const
{$i title/const.inc}

//==============================================================================

var
  SAVMSC : word absolute $58;
  VDSLST : word absolute $200;
  SDMCTL : byte absolute $22F;
  SDLSTL : word absolute $230;
  COLOR0 : byte absolute $2C4;
  COLOR1 : byte absolute $2C5;
  COLOR2 : byte absolute $2C6;
  COLOR3 : byte absolute $2C7;
  COLOR4 : byte absolute $2C8;
  HELPFG : byte absolute $2DC;           

//------------------------------------------------------------------------------  

var
  msx          : TRMT;
  priorDefault : byte;
  old_vbl      : pointer absolute $238;
  
//------------------------------------------------------------------------------

  letterColors: array [0..7] of byte;

//------------------------------------------------------------------------------

  colorStarter: array [0..7] of byte = (
     // $ba, $76, $6c, $2a, $1e, $ea, $c8, $58
     $1a, $3c, $5a, $7c, $9a, $bc, $da, $fc  
  );

//------------------------------------------------------------------------------

  bwStarter: array [0..7] of byte = (
     // $ba, $76, $6c, $2a, $1e, $ea, $c8, $58
     $00, $00, $00, $00, $02, $06, $0a, $0e  
  );

//------------------------------------------------------------------------------

  // phobia porn rhino robin pain orphan brain iron rain rip 
  _brain: array [0..4] of byte = ( _B, _R, _A, _I, _N);
  _porn: array [0..3] of byte = ( _P, _O, _R, _N);
  _pain: array [0..3] of byte = ( _P, _A, _I, _N);

//==============================================================================

{$i title/interrupts.inc}

//==============================================================================

procedure hall_of_fame; inline;
begin
  fillbyte(pointer(SCR_CREDITS), SIZE_SCREEN, 0);

  {
    0980: 8 BLANK
    0981: LMS 1000 MODE 5
    0984: 13x MODE 5
    0991: JVB 0980
  }
   poke(DL_CREDITS + $00,$70);
   poke(DL_CREDITS + $01,$45);
  dpoke(DL_CREDITS + $02, SCR_CREDITS);
  dpoke(DL_CREDITS + $04, $0505);
  dpoke(DL_CREDITS + $06, $0505);
  dpoke(DL_CREDITS + $08, $0505);
  dpoke(DL_CREDITS + $0a, $0505);
  dpoke(DL_CREDITS + $0c, $0505);
  dpoke(DL_CREDITS + $0e, $0505);
   poke(DL_CREDITS + $10, $05);
   poke(DL_CREDITS + $11, $41);
  dpoke(DL_CREDITS + $12, DL_CREDITS);

  COLOR0 := S_COLOR0; 
  COLOR1 := S_COLOR1; 
  COLOR2 := S_COLOR2; 
  COLOR3 := S_COLOR3; 
  COLOR4 := S_COLOR4;

  CHBAS := hi(CHR_MAIN);
  
  SDLSTL := DL_CREDITS;
  SAVMSC := SCR_CREDITS; 

  GotoXY(15,1); write('HALL OF FAME');

  GotoXY(6,3); write('GAME     CODE / GFX : ZBYTI');
  GotoXY(6,4); write('TITLE    CODE / GFX : BOCIANU');  
  GotoXY(6,5); write('LOADING         GFX : BOCIANU');
  GotoXY(6,6); write('GAME            SFX : BOCIANU');

  GotoXY(15,8); write('TECH SUPPORT');
  GotoXY(11,9); write('TEBE, BOCIANU, MONO');

  GotoXY(18,11); write('MUSIC');
  GotoXY(7,12); write('KJMANN, PG, XTD, P.GRABOWSKI');

  GotoXY(9,14); write('MAIN TESTERS: ZBYTI, QTZ');
end;

//------------------------------------------------------------------------------

procedure exitFromTitle;
begin
  DMACTL := 0; SDMCTL := 0;

  asm
    sei
    mva #$ff PORTB
    mva #$40 NMIEN
    cli
  end;
  
  msx.stop; PMG_Disable;

  if HELPFG = KEY_HELP_PRESSED then HELPFG := 0 else readkey;
  NoSound; 

  hall_of_fame;

  SDMCTL := $22;

  xio(40,1,0,0,'D:GAME.XEX');  
end;

//==============================================================================

procedure WaitFrames(frames: byte);
begin
  while frames>0 do begin
    WaitFrame;
    Dec(frames);

    if CRT_KeyPressed then exitFromTitle;
  end;
end;

//==============================================================================

procedure ColorRotate(delta: shortInt; count, time:byte);
var b,c,t:byte;
  src: array [0..7] of byte;
begin   
  for b:=1 to count do begin
    WaitFrames(time);
    Move(letterColors,src,8);
    for c := 0 to 7 do begin
      t := (c + delta) and 7;
      letterColors[t]:=src[c];
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure ColorChange(delta: shortInt; count, time:byte);
var b,c:byte;
begin
  for b:=1 to count do begin
    WaitFrames(time);
    for c:=0 to 7 do begin
      letterColors[c]:=letterColors[c]+delta;
    end;
  end;
end;

//------------------------------------------------------------------------------

procedure ColorStepIn(a:PByte;time:byte);
var c:byte;
begin
  for c:=7 downto 0 do begin
    ColorRotate(1,1,time);
    letterColors[0]:=a[c];
  end;
end;

//------------------------------------------------------------------------------

procedure FadeDown(time:byte);
var c,s:byte;
begin
  repeat
    s := 0;
    for c:=0 to 7 do begin
      if (letterColors[c] and 15)>0 then begin
        letterColors[c]:=letterColors[c]-1;
      end else 
        if (letterColors[c] and $f0)>0 then letterColors[c]:=0;
      s := s or letterColors[c];
    end;
    WaitFrames(time);
  until s = 0;
end;

//------------------------------------------------------------------------------

procedure BlinkWord(a:PByte;len:byte);
var c:byte;
begin
  for c:=0 to len-1 do begin
    letterColors[a[c]]:=15;
    FadeDown(1);
  end;
end;

//------------------------------------------------------------------------------

procedure Rotate3Times;
var count:byte;
begin
  ColorStepIn(@colorStarter,8);
  count:=3;
  repeat 
    ColorRotate(1,16,8);
    ColorChange(2,24,4);
    ColorRotate(-1,16,8);
    ColorChange(2,24,4);
    Dec(count);
  until count = 1;
end;

//==============================================================================

procedure vblMusic; interrupt;
begin
  msx.play;
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

begin
  set_stack;
  SetIntVec(iVBL, old_vbl);

  unapl('D:CHARSET.APL', pointer(CHR_MAIN));
  unapl('D:AXELF.APL', pointer(RMT_MUSIC));

  msx.player := pointer(RMT_PLAYER);
  msx.modul  := pointer(RMT_MODUL);
  msx.init(0);

  SystemOff($fe);
  EnableVBLI(@vblMusic);
  EnableDLI(@dli);
  DLISTL := DISPLAY_LIST_ADDRESS;
  PMG_Init(Hi(PMG_ADDRESS), %00101110, PMG_gractl_default);
  priorDefault := 4;
  prior := 4;
  fillbyte(@letterColors,8,2);
  
  ColorStepIn(@bwStarter,4);
  FadeDown(2);

  repeat 

    Rotate3Times;
    FadeDown(2);
    BlinkWord(_brain,5);
    BlinkWord(_porn,4);

    Rotate3Times;
    FadeDown(2);
    BlinkWord(_brain,5);
    BlinkWord(_pain,4);
   
  until false;
end.
