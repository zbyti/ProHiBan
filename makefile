MP=${HOME}/Programs/Mad-Pascal/mp
MADS=${HOME}/Programs/Mad-Assembler/mads
BASE=${HOME}/Programs/Mad-Pascal/base
XEX=/dev/shm/main.xex
EXO=/dev/shm/exomized
ATR=/dev/shm/disk.atr
ASM=/dev/shm/main.a65
DOS=atr/xxl_blank_180KB.atr

FREE_SPACE = $(shell atr $(ATR) ls -l | grep free)

all: prepare put_gfx put_music put_levels compile_game assamble_game put_exo_game compile_title assamble_title put_title compile_autorun assamble_autorun put_autorun info run

game: prepare put_gfx put_music put_levels compile_game assamble_game put_exo_autorun info run

compile_game:
	$(MP) game.pas -code:8C00 -o $(ASM)

compile_title:
	$(MP) title.pas -code:2000 -o $(ASM)

compile_autorun:
	$(MP) autorun.pas -code:980 -o $(ASM)

assamble_game:
	$(MADS) $(ASM) -x -i:$(BASE) -o:$(XEX)

assamble_title:
	$(MADS) $(ASM) -x -i:$(BASE) -o:$(XEX)

assamble_autorun:
	$(MADS) $(ASM) -x -i:$(BASE) -o:$(XEX)

prepare:
	rm -f $(XEX)
	rm -f $(ATR)
	cp $(DOS) $(ATR)

put_title:
	atr $(ATR) put $(XEX) title.xex

put_autorun:
	atr $(ATR) put $(XEX) autorun

put_exo_autorun:
	exomizer sfx sys -n -t 168 -Di_table_addr=0x0400 -P0 -o $(EXO) $(XEX)
	atr $(ATR) put $(EXO) autorun

put_exo_game:
	exomizer sfx sys -n -t 168 -Di_table_addr=0x0400 -P0 -o $(EXO) $(XEX)
	atr $(ATR) put $(EXO) game.xex

put_gfx:
	atr $(ATR) put gfx/charset.apl charset.apl
	atr $(ATR) put gfx/logo.apl logo.apl
	atr $(ATR) put gfx/glass.apl glass.apl
	atr $(ATR) put gfx/help.apl help.apl

put_music:
	atr $(ATR) put msx/axelf.apl axelf.apl
	atr $(ATR) put msx/beetle.apl beetle.apl
	atr $(ATR) put msx/fun.apl fun.apl
	atr $(ATR) put msx/fourth.apl fourth.apl
	atr $(ATR) put msx/sfx.apl sfx.apl

put_levels:
	atr $(ATR) put lvs/abed.apl abed.apl
	atr $(ATR) put lvs/aruba.apl aruba.apl
	atr $(ATR) put lvs/atlas.apl atlas.apl
	atr $(ATR) put lvs/boxxle.apl boxxle.apl
	atr $(ATR) put lvs/cosmac1.apl cosmac1.apl
	atr $(ATR) put lvs/cosmac2.apl cosmac2.apl
	atr $(ATR) put lvs/cosmos.apl cosmos.apl
	atr $(ATR) put lvs/duthen.apl duthen.apl
	atr $(ATR) put lvs/dzekic.apl dzekic.apl
	atr $(ATR) put lvs/garcia.apl garcia.apl
	atr $(ATR) put lvs/grigr.apl grigr.apl
	atr $(ATR) put lvs/haywood.apl haywood.apl
	atr $(ATR) put lvs/holland.apl holland.apl
	atr $(ATR) put lvs/marques.apl marques.apl
	atr $(ATR) put lvs/micro.apl micro.apl
	atr $(ATR) put lvs/reinke1.apl reinke1.apl
	atr $(ATR) put lvs/reinke2.apl reinke2.apl
	atr $(ATR) put lvs/sasq.apl sasq.apl
	atr $(ATR) put lvs/serena1.apl serena1.apl
	atr $(ATR) put lvs/serena2.apl serena2.apl
	atr $(ATR) put lvs/sharpen.apl sharpen.apl
	atr $(ATR) put lvs/various1.apl various1.apl
	atr $(ATR) put lvs/various2.apl various2.apl
	atr $(ATR) put lvs/various3.apl various3.apl
	atr $(ATR) put lvs/empty.sav progress.sav

info:
	@echo $(FREE_SPACE)

run:
	atari800 $(ATR)

save:
	cp $(ATR) atr/ProHiBan.atr
