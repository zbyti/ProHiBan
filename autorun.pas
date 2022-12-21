program autorun;

//==============================================================================

{$define basicoff}

//==============================================================================

uses aplib, cio;

//==============================================================================
const
  D_LOGO           = 'D:LOGO.APL';

  ADR_LOGO         = $8036;              // DL GR.8 $8036; GFX $8150
  ADR_LOGO_DL      = ADR_LOGO;
  ADR_LOGO_GFX     = $8150;

  L_COLOR1         = $9c;
  L_COLOR2         = $12;
  L_COLOR4         = $12;

//==============================================================================

{$i inc/registers.inc}

//==============================================================================

var
  old_vbl      : pointer absolute $238;

//==============================================================================

procedure show_logo; inline;
begin
  GetIntVec(iVBL, old_vbl);

  unapl(D_LOGO, pointer(ADR_LOGO));

  COLOR1 := L_COLOR1; 
  COLOR2 := L_COLOR2;
  COLOR4 := L_COLOR4;

  SDLSTL := ADR_LOGO_DL;
  SAVMSC := ADR_LOGO_GFX;
end;

begin
  SDMCTL := 0;

  show_logo;

  SDMCTL := $22;

  xio(40,1,0,0,'D:TITLE.XEX'); 
end.