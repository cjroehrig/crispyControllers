; Lotro definitions for 2-boxing (ASSIST/HEAL)

;===============================================================================
; Window (and fellowship) definitions

; Windowed: 1280x720
; fellows: array of titles of (possible) fellow windows in fellowship order.
; skills: array of skill keys to be controlled by other fellows.
;    ^Ctrl == target;   +Shift == assist  F1-F6 is fellow member (F1=self)
;

; ASSIST
new LotroWin( {title: "LotRO ASSIST"		
		,width:1280,		height:720,		x:0,		y:322
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
		,width:1280,		height:720,		x:0,		y:0
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
new LotroWin( {title: "LotRO INACTIVE"
		,width:1280,		height:720,		x:624,		y:0
		,bindings: KK
		,fellows:false
		,skills:false })
