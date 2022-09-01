; Lotro definitions for 2-boxing (ASSIST/ASSIST)

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
		,fellows:["LotRO AUX"]
		,select: 1			; first fellow
		; Assist first fellow (Shift F2)
		,skills:[	 "+{F2}{F1}"
					,"+{F2}{F2}"
					,"+{F2}{F3}"
					,"+{F2}{F4}"
					,"+{F2}{F5}"
					,"+{F2}{F6}" ]})

; AUX
new LotroWin( {title: "LotRO AUX"
		,winpos: LotroWinPos_topright
		,bindings: KK
		,fellows:["LotRO ASSIST"]
		,select: 1			; first fellow
		; Assist first fellow (Shift F2)
		,skills:[	 "+{F2}{F1}"
					,"+{F2}{F2}"
					,"+{F2}{F3}"
					,"+{F2}{F4}"
					,"+{F2}{F5}"
					,"+{F2}{F6}" ]})

; INACTIVE
new LotroWin( {title: LotroInactiveWinTitle
		,winpos: LotroWinPos_topleft
		,bindings: KK
		,fellows:false
		,skills:false })
