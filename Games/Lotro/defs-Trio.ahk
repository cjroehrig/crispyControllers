; CJRTrio Lotro setup for 3-boxing (dps/heal/tank)

;===============================================================================
; Window (and fellowship) definitions

; fellows: array of titles of fellow windows in fellowship order.
; skills: array of skill keys to be controlled by other fellows.
;    ^Ctrl == target;   +Shift == assist  F1-F6 is fellow member (F1=self)
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
		,select: 2			; Tank
		; DPS: Assist TANK (Shift F3)
		,skills:[	 "+{F3}{F1}"
					,"+{F3}{F2}"
					,"+{F3}{F3}"
					,"+{F3}{F4}"
					,"+{F3}{F5}"
					,"+{F3}{F6}" ]})

; HEAL
new LotroWin( {title: "LotRO HEAL"
		,winpos: LotroWinPos_topleft
		,bindings: KK
		,fellows:["LotRO DPS", "LotRO TANK"]
		,select: 2			; Tank
		; Healer: Target TANK (Ctrl F3)
		,skills:[	 "^{F3}{F1}"
					,"^{F3}{F2}"
					,"^{F3}{F3}"
					,"^{F3}{F4}"
					,"^{F3}{F5}"
					,"^{F3}{F6}" ]})

; TANK
new LotroWin( {title: "LotRO TANK"
		,winpos: LotroWinPos_topright
		,bindings: KK
		,fellows:["LotRO HEAL", "LotRO DPS"]
		,select: 1			; Healer
		; Tank: Assist DPS (Shift F3)
		,skills:[	 "+{F3}{F1}"
					,"+{F3}{F2}"
					,"+{F3}{F3}"
					,"+{F3}{F4}"
					,"+{F3}{F5}"
					,"+{F3}{F6}" ]})

; INACTIVE
new LotroWin( {title: LotroInactiveWinTitle
		,winpos: LotroWinPos_topright
		,bindings: KK
		,fellows:false
		,select:false
		,skills:false })
