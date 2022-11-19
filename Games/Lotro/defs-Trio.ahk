; Trio Lotro setup for 3-boxing (dps/heal/tank)

;===============================================================================
; Window (and fellowship) definitions

; skilltarget:	array of remote skill targets
;			-2		use the remote fellow's currtarget
;			-1		No target: don't change target/assist
;			0		self
;			1-N		target/assist that fellowship member
;			role	target/assist the first fellow with matching role (string)
;					this can also use a suffix 2,3,4,... to match other instances
; skillassist:  array of bool for each remote skill.  
;			0		target the skilltarget before firing the skill
;			1		assist the skilltarget before firing the skill
; defaulttarget:	the initial currtarget of each instance of this role
;				  	(-1, 0, 1-N, role  - as defined for skilltarget)
; defaultfellow:  the initial default recipient of all the remote skills
;					(1-N, or role)
;===============================================================================
;
; Fellowship ordering: HEAL+DPS party up first; HEAL as leader -> invite TANK
; NB:  KEEP HEAL as Fellowship Leader (if leader changes, party order changes!)
;	# 			self		N=1			N=2
;	# window	F1			F2			F3
;	DPS			DPS			HEAL		TANK
;	HEAL		HEAL		DPS			TANK
;	TANK		TANK		HEAL		DPS
;
;   This way, TANK and HEAL are always on the same select buttons (and
;	DPS will be on different select buttons when switching betw. TANK & HEAL)

; DPS
new LotroRole( "DPS"
		,{winpos: LotroWinPos_botleft
		,bindings: KK
		,skilltarget:[ -2, -2, -2, -2, -2, -2 ]		; -1=none; -2=defaulttarget
		,skillassist:[  1,  1,  1,  1,  1,  1 ]		; Assist
		,defaulttarget: 	"TANK"
		,defaultfellow: 	"HEAL"
		,_:0})

; HEAL
new LotroRole( "HEAL"
		,{winpos: LotroWinPos_topleft
		,bindings: KK
		,skilltarget:[ -2, -2, -2, -2, -2, -2 ]		; -1=none; -2=defaulttarget
		,skillassist:[  0,  0,  0,  0,  0,  0 ]		; no Assist (target)
		,defaulttarget: 	"DPS"					; (tank gets AoE heals)
		,defaultfellow: 	"TANK"
		,_:0})

; TANK
new LotroRole( "TANK"
		,{winpos: LotroWinPos_topright
		,bindings: KK
		,skilltarget:[ -2, -2, -2, -2, -2, -2 ]		; -1=none; -2=defaulttarget
		,skillassist:[  1,  1,  1,  1,  1,  1 ]		; Assist
		,defaulttarget: 	"DPS"
		,defaultfellow: 	"DPS"
		,_:0})
