; Lotro definitions

#Include Lib/ahk/util.ahk
#Include Games/Lotro/LotroWin.ahk
#Include Games/Lotro/bindingdef.ahk

; Read file to determine current Lotro mode
Fileread, LotroMode, Games/Lotro/MODE
LotroMode := RegExReplace(LotroMode, "#[^\n]*")
LotroMode := RegExReplace(LotroMode, "\s")
LotroMode := StrReplace(LotroMode, "`r")
LotroMode := StrReplace(LotroMode, "`n")


; set window positions 
switch Hostname {

case "aquila":
	; 2560x1440
	LotroWinPos_topleft  :=	{ width: 1280, 	height: 720,	x:0,	y:0		}
	LotroWinPos_topright :=	{ width: 1280, 	height: 720,	x:1264,	y:0		}
	LotroWinPos_botleft  :=	{ width: 1280, 	height: 720,	x:0,	y:682	}
	LotroWinPos_botright :=	{ width: 1280, 	height: 720,	x:1264,	y:682 	}
	LotroLayout_f := "f1440"
	LotroLayout_w := "w"
	LotroLayout_wbg := "wbg"

default:
	; 1920x1080
	LotroWinPos_topleft  :=	{ width: 1280, 	height: 720,	x:0,	y:0		}
	LotroWinPos_topright :=	{ width: 1280, 	height: 720,	x:624,	y:0		}
	LotroWinPos_botleft  :=	{ width: 1280, 	height: 720,	x:0,	y:322	}
	LotroWinPos_botright :=	{ width: 1280, 	height: 720,	x:624,	y:322 	}
	LotroLayout_f := "f"
	LotroLayout_w := "w"
	LotroLayout_wbg := "wbg"
}

Dbg( "AutoHotKey LotRO ({}) starting on host {}", LotroMode, Hostname )

; Can't #include a string or variable...
switch LotroMode {
case "DuoAH":
	#Include Games/Lotro/defs-DuoAH.ahk
case "DuoAA":
	#Include Games/Lotro/defs-DuoAA.ahk
case "Trio":
	#Include Games/Lotro/defs-Trio.ahk
default:
	Dbg("AutoHotKey LotRO: Unknown or Missing Lotro/MODE: " + LotroMode )
}


LotroWin.finalize()
;LotroWin.dumpAll()
