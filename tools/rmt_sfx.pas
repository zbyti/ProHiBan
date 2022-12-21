// RMT PLAYER
//procedure Sfx(effect, channel, note: byte); assembler;

uses crt, rmt;

const
	rmt_player = $5600;
	rmt_modul  = $5a00;

var
	msx: TRMT;

{$r 'rmt_sfx.rc'}

procedure vbl; interrupt;
begin
	//msx.play;
	asm jmp sysvbv end;
end;

begin
	NoSound;
	msx.player := pointer(rmt_player);
	msx.modul  := pointer(rmt_modul);
	//msx.init(0);

	SetIntVec(iVBLI, @vbl);
	writeln('Pascal RMT player example');

	repeat
		//pause(25);
		//msx.sfx(2,0,$80);
		//write('pyk...');
	until keypressed;

	msx.stop;

end.

