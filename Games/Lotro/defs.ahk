; Lotro configuration

#Include Lib/ahk/util.ahk
#Include Lib/ahk/numerical.ahk
#Include Games/Lotro/LotroWin.ahk

; define window positions 
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

;	; XXX: MODES not needed anymore; just define all Roles here.
;	; Read file to determine current Lotro mode
;	Fileread, LotroMode, Games/Lotro/MODE
;	LotroMode := RegExReplace(LotroMode, "#[^\n]*")
;	LotroMode := RegExReplace(LotroMode, "\s")
;	LotroMode := StrReplace(LotroMode, "`r")
;	LotroMode := StrReplace(LotroMode, "`n")
;
;	; Can't #include a string or variable...
;	switch LotroMode {
;	case "Trio":
;		#Include Games/Lotro/defs-Trio.ahk
;	default:
;		Dbg("AutoHotKey LotRO: Unknown or Missing Lotro/MODE: " + LotroMode )
;	}
;	Dbg( "AutoHotKey LotRO ({}) starting on host {}", LotroMode, Hostname )



	Dbg( "AutoHotKey LotRO starting on host {}", Hostname )


;==============================================================================
; Lotro bindings (used internally by LotroWin)
; NB: these must be in AutoHotKey Send format
LotroBindings := {_:0

	,forward		: "e"								; move forward
	,follow			: "+{Tab}" 							; follow target
	,steedhalt		: "c"								; warsteed halt

	; keys to target/assist fellows 1-6  (1 == self)
	; These are as you have defined them within LotRO itself.
	; NB: ^ == Control; + == Shift; ! == Alt 
	,target 		: [  "^{F1}", "^{F2}", "^{F3}"
						,"^{F4}", "^{F5}", "^{F6}" ]
	,assist 		: [  "+{F1}", "+{F2}", "+{F3}"
						,"+{F4}", "+{F5}", "+{F6}" ]

	; keys for remote-use skills.
	; You can have more (or fewer) than 6, but they must be matched 
	; in skilltarget and skillassist arrays in your defs-* files.
	; NB: these keys should also have hotkey definitions in mappings.ahk 
	,skills 		: [  "{F1}", "{F2}", "{F3}"
						,"{F4}", "{F5}", "{F6}" ]

	,_:0}

;===============================================================================
; Role Definitions

; skilltarget:	array of skill targets (when activated remotely)
;			-2		use currtarget
;			-1		No target: don't change target/assist
;			0		self
;			1-N		target/assist that fellowship member
;			role	target/assist the first fellow with matching role (string)
;					this can also use a suffix 2,3,... to match other instances
; skillassist:  array of bool for each remote skill.  
;			0		target the skilltarget before firing the skill
;			1		assist the skilltarget before firing the skill
; defaulttarget:	the initial currtarget of each instance of this role
;				  	(-1, 0, 1-N, role  - as defined for skilltarget)
; defaultfellow:  the initial default recipient of all the remote skills
;					(1-N, or role)
;===============================================================================
; Trio fellowship ordering tips:
;    - HEAL+DPS party up first; HEAL as leader -> invite TANK
;    - Keep HEAL as Fellowship Leader (if leader changes, party order changes!)
;	# 			self		N=1			N=2
;	# window	^F1			^F2			^F3
;	DPS			DPS			HEAL		TANK
;	HEAL		HEAL		DPS			TANK
;	TANK		TANK		HEAL		DPS
;   This way, HEAL is always SELECT 1 and TANK is always SELECT 2 (buttons).


;===========================================================
; DPS
new LotroRole( "DPS"
		,{winpos: LotroWinPos_botleft
		,bindings: LotroBindings
		,skilltarget:[ -2, -2, -2, -2, -2, -2 ]		; -1=none; -2=defaulttarget
		,skillassist:[  1,  1,  1,  1,  1,  1 ]		; Assist
		,defaulttarget: 	"TANK"
		,defaultfellow: 	"HEAL"
		,_:0})

;===========================================================
; HEAL
new LotroRole( "HEAL"
		,{winpos: LotroWinPos_topleft
		,bindings: LotroBindings
		,skilltarget:[ -2, -2, -2, -2, -2, -2 ]		; -1=none; -2=defaulttarget
		,skillassist:[  0,  0,  0,  0,  0,  0 ]		; no Assist (target)
		,defaulttarget: 	"DPS"					; (tank gets AoE heals)
		,defaultfellow: 	"TANK"
		,_:0})

;===========================================================
; TANK
new LotroRole( "TANK"
		,{winpos: LotroWinPos_topright
		,bindings: LotroBindings
		,skilltarget:[ -2, -2, -2, -2, -2, -2 ]		; -1=none; -2=defaulttarget
		,skillassist:[  1,  1,  1,  1,  1,  1 ]		; Assist
		,defaulttarget: 	"DPS"
		,defaultfellow: 	"DPS"
		,_:0})
