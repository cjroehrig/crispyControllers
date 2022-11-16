; Lotro definitions for 2-boxing (DPS/HEAL)

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
;	# 			self		N=1			N=2
;	# window	F1			F2			F3
;	DPS			DPS			HEAL
;	HEAL		HEAL		DPS	

; DPS
new LotroWin( {title: "LotRO DPS"		
		,winpos: LotroWinPos_botleft
		,bindings: KK
		,fellows:["LotRO HEAL"]
		,skilltarget:[ -2, -2, -2, -2, -2, -2 ]		; -1=none; -2=defaulttarget
		,skillassist:[  1,  1,  1,  1,  1,  1 ]		; Assist
		,defaulttarget: 	1						; Heal
		,defaultfellow: 	1						; Heal
		,_:0})

; HEAL
new LotroWin( {title: "LotRO HEAL"
		,winpos: LotroWinPos_topright
		,bindings: KK
		,fellows:["LotRO DPS"]
		,skilltarget:[ -2, -2, -2, -2, -2, -2 ]		; -1=none; -2=defaulttarget
		,skillassist:[  0,  0,  0,  0,  0,  0 ]		; Target
		,defaulttarget: 	1						; DPS
		,defaultfellow: 	1						; DPS
		,_:0})

; INACTIVE
new LotroWin( {title: LotroInactiveWinTitle
		,winpos: LotroWinPos_topleft
		,bindings: KK
		,fellows:false
		,skilltarget:false
		,skillassist:false
		,defaulttarget:false
		,defaultfellow:false
		,_:0})
