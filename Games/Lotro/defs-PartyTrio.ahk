; PartyTrioMel Lotro setup for 3-boxing (heal/heal/tank) with a full party
; Identical to CJRTrio except DPS assists fellow 4 instead of tank.

;===============================================================================
; Window (and fellowship) definitions

; Windowed: 1280x720
; fellows: array of titles of fellow windows in fellowship order.
; skills: array of skill keys to be controlled by other fellows.
;    ^Ctrl == target;   +Shift == assist  F1-F6 is fellow member (F1=self)
;
; Fellowship ordering: HEAL+DPS party up first; HEAL as leader -> invite TANK
; Then invite other party members with main assist first.
; NB:  KEEP HEAL as Fellowship Leader
;     - If leadership changes, party order will also change!
;	    (leader will always be on top).
;	# 			self		N=1			N=2
;	# window	F1			F2			F3			F4			F5
;	DPS			Daer		Mel			Beo			Vehr		Boph
;	HEAL		Mel			Daer		Beo			Vehr		Boph
;	Tank		Beo			Mel			Daer		Vehr		Boph
;
;   This way, TANK and HEAL are always on the same select buttons (and
;	DPS will be on different select buttons when switching betw. TANK & HEAL)

; DPS
new LotroWin( {title: "LotRO DPS"		
		,width:1280,		height:720,		x:0,		y:322
		,bindings: KK
		,fellows:["LotRO HEAL", "LotRO TANK"]
		,select: 2			; Tank
		; DPS: Assist Vehr (Shift F4)
		,skills:[	 "+{F4}{F1}"
					,"+{F4}{F2}"
					,"+{F4}{F3}"
					,"+{F4}{F4}"
					,"+{F4}{F5}"
					,"+{F4}{F6}" ]})

; HEAL
new LotroWin( {title: "LotRO HEAL"
		,width:1280,		height:720,		x:0,		y:0
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
		,width:1280,		height:720,		x:624,		y:0
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
		,width:1280,		height:720,		x:624,		y:0
		,bindings: KK
		,fellows:false
		,select:false
		,skills:false })
