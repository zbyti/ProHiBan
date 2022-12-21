(*
 27.02.2009 - 15.10.2011 by Tebe/Madteam

 06.08.2011 -  SDX_BLK: add SDX file information (Mono / Jerzy Kut)
 15.10.2011 - MADS_BLK: add MADS block update external
 01.09.2018 -  SDX_BLK: info o aktualizowanych adresach w blokach relokowanych '-det' (Mono / Jerzy Kut)
 30.12.2019 -  LoadPCK: add LZ4 block (XXL / Krzysztof Dudek)

 Free Pascal Compiler, http://www.freepascal.org/
 Compile: fpc -Mdelphi -vh -O3 chkxex.pas
*)

program checkXEX;

//uses SysUtils;

type
  ModeType = ( atari, sparta );

var
  p: integer;
  m: ModeType;
  d: boolean;
  buf: array [0..$FFFF] of byte;
  blkad: array[0..7] of integer;
  blk: array[0..7] of array[0..$FFFF] of byte;

  plik: file;


function TestFile(var a: string): Boolean;
(*----------------------------------------------------------------------------*)
(*  sprawdzamy istnienie pliku na dysku bez udzialu 'SysUtils',               *)
(*  jest to odpowiednik funkcji 'FileExists'                                  *)
(*----------------------------------------------------------------------------*)
var IORes: integer;
    pl: textfile;
begin
 Result:=true;

 AssignFile(pl, a);
 {$I-}
 FileMode:=0;
 Reset(pl);
 {$I+ }
 IORes:=IOResult;

 if IORes<>0 then Result:=false else CloseFile(pl);
end;


function Hex(a:cardinal; b:shortint): string;
(*----------------------------------------------------------------------------*)
(*  zamiana na zapis hexadecymalny                                            *)
(*  'B' okresla maksymalna liczbe nibbli do zamiany                           *)
(*  jesli sa jeszcze jakies wartosci to kontynuuje zamiane                    *)
(*----------------------------------------------------------------------------*)
var v: byte;

const
    tHex: array [0..15] of char =
    ('0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F');

begin
 Result:='';

 while (b>0) or (a<>0) do begin

  v := byte(a);
  Result:=tHex[v shr 4] + tHex[v and $0f] + Result;

  a:=a shr 8;

  dec(b,2);
 end;

end;


procedure get(const i: integer; var len: integer);
begin
 blockread(plik, buf, i);

 inc(len, i);
end;


function ToDec(v, n: integer): string;
const
    tDec: array [0..9] of char =
    ('0','1','2','3','4','5','6','7','8','9');
var i: integer;
begin
  Result:='';
  for i:= 0 to n-1 do begin
    Result:=tDec[v mod 10]+Result;
    v:=v div 10;
  end;
end;


function GetUpdateBlock(var flen, i: integer; det: boolean): boolean;
var
  a: integer = 0;
  b: integer;
  n: byte = 0;
begin

  Result:=true;
  while true do begin
    if i+1>flen then begin Result:=false; Break end;
    get(1, i);
    case buf[0] of
      $ff: a := a + $fa;
      $fe: begin
          if i+1>flen then begin Result:=false; Break end;
          get(1, i);
	  n := buf[0];
	  a := blkad[n];
        end;
      $fd: begin
          if i+2>flen then begin Result:=false; Break end;
          get(2, i);
	  a := buf[0]+buf[1] shl 8;
          b := a-blkad[n];
          if det then writeln('        (#'+Hex(n,2)+':$'+Hex(a,4)+') = $'+Hex(blk[n][b]+blk[n][b+1] shl 8,4));
        end;
      $fc: Break;
    else begin
        a := a + buf[0];
        b := a-blkad[n];
        if det then writeln('        (#'+Hex(n,2)+':$'+Hex(a,4)+') = $'+Hex(blk[n][b]+blk[n][b+1] shl 8,4));
      end
    end;
  end;
end;


procedure LoadPCK(var i: integer; var ok: Boolean; x, no, flen: integer);
var token, LenHL, lz4, lz4s: integer;

label unlz4, getLength_next, getLength_next1, unlz4done;

begin

      if i+1>flen then begin ok:=false; Exit end;	// xxl: pomin ID dekompresora
      get(1, i);
      lz4:=0; lz4s:=0; LenHL:=0;
unlz4:
                  if i+1>flen then begin ok:=false; Exit end;
                  get(1, i); inc(lz4s, 1);
                  token:=buf[0];
                  if (buf[0] shr 4)<>0 then begin
                    LenHL:=buf[0] shr 4;
                    if LenHL=$0F then begin
getLength_next:        if i+1>flen then begin ok:=false; Exit end;
                       get(1, i); LenHL:=LenHL+buf[0];
                       if buf[0]=$FF then goto getLength_next;
                    end;
                    if i+LenHL>flen then begin ok:=false; Exit end;
                    get(LenHL, i); lz4:=lz4+LenHL; inc(lz4s, LenHL);
                  end;

                  if i+2>flen then begin ok:=false; Exit end;
                  get(2, i); inc(lz4s,2);
                  if buf[0]+buf[1]=0 then goto unlz4done;

                  LenHL:= $04+(token AND $0F);
                  if LenHL=$13 then begin
getLength_next1:     if i+1>flen then begin ok:=false; Exit end;
                     get(1, i); LenHL:=LenHL+buf[0]; inc(lz4s,1);
                     if buf[0]=$FF then goto getLength_next1;
                  end;
                  lz4:=lz4+LenHL;
                  goto unlz4;
unlz4done:

 writeln(ToDec(no,3)+':     $'+Hex(x,4)+' $'+Hex(x+lz4-1,4)+': $'+Hex(lz4,4)+' (LZ4:'+Hex(lz4s,4)+')')

end;


procedure LoadXEX(fnam: string; mode: ModeType; details: boolean);
var t, r, a: string;
    h, b, x, y, flen, i, s, no: integer;
    ok: Boolean;
    tp: char;


procedure MADS_BLK;
var l, n: integer;
begin

    if h=$FFEE then begin		// MADS BLK UPDATE EXTERNAL

	get(5, i);

	tp:=chr(buf[0]);

	n:=buf[1]+buf[2] shl 8;
	b:=buf[3]+buf[4] shl 8;

	get(b, i);
	t:='';
	for l := 0 to b-1 do t:=t+chr(buf[l]);

	for l := 0 to n-1 do begin

	 if tp='>' then
	  get(3, i)
	 else
	  get(2, i);

	 writeln(ToDec(no,3)+': MADS : '+tp+' $'+Hex(buf[0]+buf[1] shl 8,4)+' '+t+#9+'SYMBOL EXTERNAL');
	end;

	inc(no);

    end;

end;


procedure DOS_BLK;
var l: integer;
begin

    // atari dos block or sparta non-relocatable block
    if (h=$FFFF) or ((mode=sparta) and (h=$FFFA)) then begin
      if i+2>flen then begin ok:=false; Exit end;
      get(2, i);
    end;

    x:=buf[0]+buf[1] shl 8;
    if i+2>flen then begin ok:=false; Exit end;
    get(2, i);
    y:=buf[0]+buf[1] shl 8;


    if y = 0 then

     LoadPCK(i, ok, x, no, flen)			// LZ4

    else begin

     l:=y-x+1;

     if i+l>flen then begin ok:=false; Exit end;
     get(l, i);

    end;


    if y <> 0 then
    if (mode=sparta) and (h=$FFFA) then
     writeln(ToDec(no,3)+': @$'+Hex(s,4)+' SDX $'+Hex(x,4)+'-$'+Hex(y,4)+': $'+Hex(y-x+1,4)+'           SPARTA')
    else
     writeln(ToDec(no,3)+': @$'+Hex(s,4)+'     $'+Hex(x,4)+'-$'+Hex(y,4)+': $'+Hex(y-x+1,4));

    if (x<=$2e0) and (y>=$2e3) then begin
     writeln('            RUN $'+Hex(buf[0]+buf[1] shl 8,4));
     writeln('            INI $'+Hex(buf[2]+buf[3] shl 8,4));
    end else begin

     if (x<=$2e0) and (y>=$2e1) then writeln('            RUN $'+Hex(buf[0]+buf[1] shl 8,4));
     if (x<=$2e2) and (y>=$2e3) then writeln('            INI $'+Hex(buf[0]+buf[1] shl 8,4));

    end;

end;


procedure SDX_BLK;
var l, c, n: integer;
begin

  if (mode=sparta) and (h=$FFFE) then begin
    // sparta relocatable block
    if i+6>flen then begin ok:=false; Exit end;
    get(6, i);

    n:=buf[0];
    b:=buf[1];
    x:=buf[2]+buf[3] shl 8;
    y:=buf[4]+buf[5] shl 8;

    blkad[n] := x;
    l:=y;
    if (b and $80)=0 then begin
      if i+l>flen then begin ok:=false; Exit end;
      get(l, i);
      for c := 0 to l do blk[n][c] := buf[c];
    end;

    if (b and $3f)=0 then t:='MAIN'
    else if (b and $3f)=2 then t:='EXTENDED'
    else t:='$'+Hex(b and $3f,2);
    if (b and $80)=$80 then r:='EMPTY'
    else r:='RELOC';
    if (b and $40)=$40 then a:='PAGE'
    else a:='BYTE';
    writeln(ToDec(no,3)+': @$'+Hex(s,4)+' SDX $'+Hex(x,4)+'   #'+Hex(n,1)+': $'+Hex(y,4)+'           '+r+' '+t+' '+a);
  end
  else if (mode=sparta) and (h=$FFFD) then begin
    //sparta addr update block
    if i+3>flen then begin ok:=false; Exit end;
    get(3, i);

    n:=buf[0];
    y:=buf[1]+buf[2] shl 8;

    writeln(ToDec(no,3)+': @$'+Hex(s,4)+' SDX         #'+Hex(n,1)+': $'+Hex(y,4)+'           ADDR UPDATE');
    if not GetUpdateBlock(flen, i, details) then begin ok:=false; Exit end;

  end
  else if (mode=sparta) and (h=$FFFC) then begin
    //sparta symbol definition block
    if i+11>flen then begin ok:=false; Exit end;
    get(11, i);

    x:=buf[1]+buf[2] shl 8;
    setlength(t,8); for n:=0 to 7 do t[1+n]:=Chr(buf[3+n]);
    n:=buf[0];

    writeln(ToDec(no,3)+': @$'+Hex(s,4)+' SDX $'+Hex(x,4)+'   #'+Hex(n,1)+':       @'+t+' SYMBOL NEW');
  end
  else if (mode=sparta) and (h=$FFFB) then begin
    //sparta symbol update block
    if i+10>flen then begin ok:=false; Exit end;
    get(10, i);

    setlength(t,8); for n:=0 to 7 do t[1+n]:=Chr(buf[n]);
    y:=buf[8]+buf[9] shl 8;

    writeln(ToDec(no,3)+': @$'+Hex(s,4)+' SDX            : $'+Hex(y,4)+' @'+t+' SYMBOL UPDATE');
    if not GetUpdateBlock(flen, i, details) then begin ok:=false; Exit end;

  end;


end;



begin

  if not(TestFile(fnam)) then begin
   writeln('File ''',fnam,''' not found.');
   exit;
  end;

  assignfile(plik, fnam); reset(plik,1);
  flen:=FileSize(plik);

  writeln('File ''',fnam,'''');
  i:=0;

  get(16, i);

  h:=buf[0]+buf[1] shl 8;
  if (h<$FFFA) or (mode=atari) and (h<$FFFF) then begin
   writeln('Invalid file header.');
   exit;
  end;

  if (h=$ffff) and (buf[2]=0) and (buf[3]=0) and (buf[6]=$4d) and (buf[7]=$52) then begin
   writeln('MADS RELOC not supported.');
   exit;
  end;


// odczyt pliku w formacie Atari DOS lub Sparta DOS

 reset(plik,1);
 i:=0;

 ok:=true;

 no:=1;

 while i<flen do begin
  s := i;

  if i+2>flen then begin ok:=false; Break end;
  get(2, i);
  h:=buf[0]+buf[1] shl 8;

  writeln(hexStr(h,4));

  if (mode=sparta) and ((h=$FFFE) or (h=$FFFD) or (h=$FFFC) or (h=$FFFB)) then SDX_BLK else
  if h = $FFEE then MADS_BLK else
//  if ((mode=sparta) and (h=$FFFA)) or (h=$FFFF) then DOS_BLK else
  DOS_BLK;

  inc(no, 1);
 end;

 writeln('     @$'+Hex(i,4)+' EOF');


 if (i<>flen) or not(ok) then
  writeln('File ''',fnam,''' is too short.')
 else
  writeln('File ''',fnam,''' is OK.');

 closefile(plik);
end;


begin

 if ParamCount>0 then
   begin
     p := 1;
     m := sparta;
     d := false;
     while p <= ParamCount do
     begin
       if ParamStr(p) = '-std' then m := atari
       else
         if ParamStr(p) = '-det' then d := true
         else LoadXEX( ParamStr(p), m, d );
       p := p + 1;
     end
   end
 else
   writeln('Syntax: chkxex [-std] [-det] filename.xex');

end.
