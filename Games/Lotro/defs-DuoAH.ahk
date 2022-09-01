; Lotro definitions for 2-boxing (ASSIST/HEAL)

;===============================================================================
; Window (and fellowship) definitions

; fellows: array of titles of (possible) fellow windows in fellowship order.
; skills: array of skill keys to be controlled by other fellows.
;    ^Ctrl == target;   +Shift == assist  F1-F6 is fellow member (F1=self)
;

; ASSIST
new LotroWin( {title: "LotRO ASSIST"		
		,winpos: LotroWinPos_botleft
		,bindings: KK
		,fellows:["LotRO HEAL"]
		,select: 1			; first fellow
		; ASSIST first fellow (Shift F2)
		,skills:[	 "+{F2}{F1}"
					,"+{F2}{F2}"
					,"+{F2}{F3}"
					,"+{F2}{F4}"
					,"+{F2}{F5}"
					,"+{F2}{F6}" ]})

; HEAL
new LotroWin( {title: "LotRO HEAL"
		,winpos: LotroWinPos_topright
		,bindings: KK
		,fellows:["LotRO ASSIST"]
		,select: 1			; first fellow
		; HEAL: Target first fellow (Ctrl F2)
		,skills:[	 "^{F2}{F1}"
					,"^{F2}{F2}"
					,"^{F2}{F3}"
					,"^{F2}{F4}"
					,"^{F1}{F5}"				; F1: SELF heal
					,"^{F2}{F6}" ]})

; INACTIVE
new LotroWin( {title: LotroInactiveWinTitle
		,winpos: LotroWinPos_topleft
		,bindings: KK
		,fellows:false
		,skills:false })
