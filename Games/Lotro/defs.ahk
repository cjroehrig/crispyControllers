; Lotro definitions

#Include Lib/ahk/util.ahk
#Include Games/Lotro/LotroWin.ahk
#Include Games/Lotro/bindingdef.ahk

; Read file to determine current Lotro mode

Fileread, LotroMode, Games/Lotro/MODE
LotroMode := StrReplace(LotroMode, "`r")
LotroMode := StrReplace(LotroMode, "`n")

Dbg( "AutoHotKey LotRO ({}) starting", LotroMode )

if ( LotroMode == "DuoAH" ) {
	#Include Games/Lotro/defs-DuoAH.ahk
} else if ( LotroMode == "DuoAA" ) {
	#Include Games/Lotro/defs-DuoAA.ahk
} else if ( LotroMode == "Trio" ) {
	#Include Games/Lotro/defs-Trio.ahk
} else if ( LotroMode == "PartyDuo" ) {
	#Include Games/Lotro/defs-PartyDuo.ahk
} else if ( LotroMode == "PartyDuoBeo" ) {
	#Include Games/Lotro/defs-PartyDuoBeo.ahk
} else if ( LotroMode == "PartyTrio" ) {
	#Include Games/Lotro/defs-PartyTrio.ahk
} else {
	Dbg("AutoHotKey LotRO: Unknown or Missing Lotro/MODE: " + LotroMode )
}


LotroWin.finalize()
;LotroWin.dumpAll()
