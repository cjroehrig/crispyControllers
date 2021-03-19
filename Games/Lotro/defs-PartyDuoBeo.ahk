; CJRPartyDuoBeo Lotro setup for 2-boxing (tank/heal) with my full party

;===============================================================================
; Window (and fellowship) definitions

; Windowed: 1280x720
; fellows: array of titles of fellow windows in fellowship order.
; skills: array of skill keys to be controlled by other fellows.
;    ^Ctrl == target;   +Shift == assist  F1-F6 is fellow member (F1=self)
;
;	# 			self		N=1			N=2
;	# window	F1			F2			F3			F4			F5
;	TANK		Beo			Est			Boph		Vehr		
;	HEAL		Est			Beo			Boph		Vehr		
;
; TANK
new LotroWin( {title: "LotRO TANK"		
		,width:1280,		height:720,		x:0,		y:322
		,bindings: KK
		,fellows:["LotRO HEAL"]
		,select: 1			; HEAL
		; TANK: Assist Vehr (Shift F4)
		,skills:[	 "+{F4}{F1}"
					,"+{F4}{F2}"
					,"+{F4}{F3}"
					,"+{F4}{F4}"
					,"+{F4}{F5}"
					,"+{F4}{F6}" ]})

; HEAL
new LotroWin( {title: "LotRO HEAL"
		,width:1280,		height:720,		x:624,		y:0
		,bindings: KK
		,fellows:["LotRO TANK"]
		,select: 1			; TANK
		; Healer: Target Beo (Tank) (Ctrl F3)
		,skills:[	 "^{F2}{F1}"
					,"^{F2}{F2}"
					,"^{F2}{F3}"
					,"^{F2}{F4}"
					,"^{F2}{F5}"
					,"^{F2}{F6}" ]})


; INACTIVE
new LotroWin( {title: LotroInactiveWinTitle
		,width:1280,		height:720,		x:0,		y:0
		,bindings: KK
		,fellows:false
		,select:false
		,skills:false })
