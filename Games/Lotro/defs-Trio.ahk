; Trio Lotro setup for 3-boxing (dps/heal/tank)

;===============================================================================
; Window (and fellowship) definitions

; fellows: array of titles of fellow windows in fellowship order.
; skilltarget:  array of targets for each remote skill (bindings.skills)
;			-2		use default target
;			-1		No target: don't change target/assist
;			0		self
;			1-N		target/assist that fellowship member
; skillassist:  array of bool for each remote skill.  
;			0		target the skilltarget before firing the skill
;			1		assist the skilltarget before firing the skill
; defaulttarget:  as defined in skilltarget but can be changed on the fly
; defaultfellow:  the default recipient of all the remote skills
;===============================================================================
;
; Fellowship ordering: HEAL+DPS party up first; HEAL as leader -> invite TANK
; NB:  KEEP HEAL as Fellowship Leader
;     - If leadership changes, party order will also change!
;	    (leader will always be on top).
;	# 			self		N=1			N=2
;	# window	F1			F2			F3
;	DPS			DPS			HEAL		TANK
;	HEAL		HEAL		DPS			TANK
;	TANK		TANK		HEAL		DPS
;
;   This way, TANK and HEAL are always on the same select buttons (and
;	DPS will be on different select buttons when switching betw. TANK & HEAL)

; DPS
new LotroWin( {title: "LotRO DPS"		
		,winpos: LotroWinPos_botleft
		,bindings: KK
		,fellows:["LotRO HEAL", "LotRO TANK"]
		,skilltarget:[ -2, -2, -2, -2, -2, -2 ]		; -1=none; -2=defaulttarget
		,skillassist:[  1,  1,  1,  1,  1,  1 ]		; Assist
		,defaulttarget: 	2						; Tank
		,defaultfellow: 	1						; Heal
		,_:0})

; HEAL
new LotroWin( {title: "LotRO HEAL"
		,winpos: LotroWinPos_topleft
		,bindings: KK
		,fellows:["LotRO DPS", "LotRO TANK"]
		,skilltarget:[ -2, -2, -2, -2, -2, -2 ]		; -1=none; -2=defaulttarget
		,skillassist:[  0,  0,  0,  0,  0,  0 ]		; no Assist (target)
		,defaulttarget: 	1						; DPS [tank gets AoE heals]
		,defaultfellow: 	2						; Tank
		,_:0})

; TANK
new LotroWin( {title: "LotRO TANK"
		,winpos: LotroWinPos_topright
		,bindings: KK
		,fellows:["LotRO HEAL", "LotRO DPS"]
		,skilltarget:[ -2, -2, -2, -2, -2, -2 ]		; -1=none; -2=defaulttarget
		,skillassist:[  1,  1,  1,  1,  1,  1 ]		; Assist
		,defaulttarget: 	2						; DPS
		,defaultfellow: 	2						; DPS
		,_:0})

; INACTIVE
new LotroWin( {title: LotroInactiveWinTitle
		,winpos: LotroWinPos_topright
		,bindings: KK
		,fellows:false
		,skilltarget:false
		,skillassist:false
		,defaulttarget:false
		,defaultfellow:false
		,_:0})
