; Lotro definitions

#Include Lib/ahk/util.ahk
#Include Games/Lotro/LotroWin.ahk
#Include Games/Lotro/bindingdef.ahk

; Read file to determine current Lotro mode

Fileread, LotroMode, Games/Lotro/MODE
LotroMode := StrReplace(LotroMode, "`r")
LotroMode := StrReplace(LotroMode, "`n")

if ( LotroMode == "Solo" ) {
	Dbg("AutoHotKey LotRO (Solo) starting")
	#Include Games/Lotro/defs-Solo.ahk
} else if ( LotroMode == "Party" ) {
	Dbg("AutoHotKey LotRO (Party) starting")
	#Include Games/Lotro/defs-Party.ahk
} else if ( LotroMode == "Trio" ) {
	Dbg("AutoHotKey LotRO (Trio) starting")
	#Include Games/Lotro/defs-Trio.ahk
} else {
	Dbg("AutoHotKey LotRO: Unknown or Missing Lotro/MODE: " + LotroMode )
}


LotroWin.finalize()
;LotroWin.dumpAll()
