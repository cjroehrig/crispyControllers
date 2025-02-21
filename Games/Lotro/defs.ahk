; Lotro configuration

#Include Lib/ahk/util.ahk
#Include Lib/ahk/numerical.ahk
#Include Games/Lotro/LotroWin.ahk

LotroWP := []		; declare array of winpos

switch Hostname {

case "aquila":
	; Screensize: 2560x1440
	; Nominal windowed size: 720p (1280x720)

	LotroWP[0]  :=	{ x:0,		y:0,	lo:"1440",	lo_bg:"1440_bg" } ;fullscrn
	LotroWP[1]  :=	{ x:0,		y:0,	lo:"720",	lo_bg:"720_bg" } ; top left
	LotroWP[2]  :=	{ x:1264,	y:0,	lo:"720",	lo_bg:"720_bg" } ; top right
	LotroWP[3]  :=	{ x:0,		y:682,	lo:"720",	lo_bg:"720_bg" } ; bot left
	LotroWP[4]  :=	{ x:1264,	y:682, 	lo:"720",	lo_bg:"720_bg" } ; bot right
	LotroWP[5]  :=	{ x:78,		y:324, 	lo:"1920",	lo_bg:"1920_bg" } ; big

default:
	; Screensize: 1920x1080 
	; Nominal windowed size: 720p (1280x720)
	LotroWP[0]  :=	{ x:0,		y:0,	lo:"1920",	lo_bg:"1920_bg" } ;fullscrn
	LotroWP[1]  :=	{ x:0,		y:0,	lo:"720",	lo_bg:"720_bg" } ; top left
	LotroWP[2]  :=	{ x:624,	y:0,	lo:"720",	lo_bg:"720_bg" } ; top right
	LotroWP[3]  :=	{ x:0,		y:322,	lo:"720",	lo_bg:"720_bg" } ; bot left
	LotroWP[4]  :=	{ x:624,	y:322, 	lo:"720",	lo_bg:"720_bg" } ; bot right
	LotroWP[5]  :=	{ x:0,		y:322, 	lo:"720",	lo_bg:"720_bg" } ; big
}

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
		,{bindings: LotroBindings
		,skilltarget:[ -2, -2, -2, -2, -2, -2 ]		; -1=none; -2=defaulttarget
		,skillassist:[  1,  1,  1,  1,  1,  1 ]		; Assist
		,defaulttarget: 	"TANK"
		,defaultfellow: 	"HEAL"
		,winpos: LotroWP[3]							; bot left
		,_:0})

;===========================================================
; HEAL
new LotroRole( "HEAL"
		,{bindings: LotroBindings
		,skilltarget:[ -2, -2, -2, -2, -2, -2 ]		; -1=none; -2=defaulttarget
		,skillassist:[  0,  0,  0,  0,  0,  0 ]		; no Assist (target)
		,defaulttarget: 	"DPS"					; (tank gets AoE heals)
		,defaultfellow: 	"TANK"
		,winpos: LotroWP[1]							; top left
		,_:0})

;===========================================================
; TANK
new LotroRole( "TANK"
		,{bindings: LotroBindings
		,skilltarget:[ -2, -2, -2, -2, -2, -2 ]		; -1=none; -2=defaulttarget
		,skillassist:[  1,  1,  1,  1,  1,  1 ]		; Assist
		,defaulttarget: 	"DPS"
		,defaultfellow: 	"DPS"
		,winpos: LotroWP[2]							; top right
		,_:0})
