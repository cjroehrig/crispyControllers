; CJRTrio Lotro setup for 3-boxing (dps/heal/tank)

;===============================================================================
; Window (and fellowship) definitions

; Windowed: 1280x720
; fellows: array of titles of fellow windows in fellowship order.
; skills: array of skill keys to be controlled by other fellows.
;    ^Ctrl == target;   +Shift == assist  F1-F6 is fellow member (F1=self)
;
; Fellowship ordering: MAIN+AUX party up first; AUX leader -> invite TERTIARY
; NB:  KEEP AUX as Fellowship Leader
;     - If leadership changes, party order will also change!
;	    (leader will always be on top).
;		MAIN=DPS;  AUX=Healer;		TERTIARY=Tank
;	# 			self		N=1			N=2
;	# window	F1			F2			F3
;	MAIN		MAIN		AUX		TERTIARY
;	AUX			AUX			MAIN	TERTIARY
;	TERTIARY	TERTIARY	AUX		MAIN
;
;   This way, Tank and Healer are always on the same select buttons (and
;	DPS will be on different select buttons when switching betw. Tank & Healer)

; MAIN -- DPS
new LotroWin( {title: "LotRO MAIN"		
		,width:1280,		height:720,		x:0,		y:322
		,bindings: KK
		,fellows:["LotRO AUX", "LotRO TERTIARY"]
		,select: 2			; Tank
		; DPS: Assist Tank TERTIARY (Shift F3)
		,skills:[	 "+{F3}{F1}"
					,"+{F3}{F2}"
					,"+{F3}{F3}"
					,"+{F3}{F4}"
					,"+{F3}{F5}"
					,"+{F3}{F6}" ]})

; AUX -- Healer
new LotroWin( {title: "LotRO AUX"
		,width:1280,		height:720,		x:624,		y:0
		,bindings: KK
		,fellows:["LotRO MAIN", "LotRO TERTIARY"]
		,select: 2			; Tank
		; Healer: Target Tank TERTIARY (Ctrl F3)
		,skills:[	 "^{F3}{F1}"
					,"^{F3}{F2}"
					,"^{F3}{F3}"
					,"^{F3}{F4}"
					,"^{F3}{F5}"
					,"^{F3}{F6}" ]})

; AUX3 -- Tank
new LotroWin( {title: "LotRO TERTIARY"
		,width:1280,		height:720,		x:0,		y:0
		,bindings: KK
		,fellows:["LotRO AUX", "LotRO MAIN"]
		,select: 1			; Healer
		; Tank: Assist DPS MAIN (ShiftF3)
		,skills:[	 "+{F3}{F1}"
					,"+{F3}{F2}"
					,"+{F3}{F3}"
					,"+{F3}{F4}"
					,"+{F3}{F5}"
					,"+{F3}{F6}" ]})

; INACTIVE
new LotroWin( {title: "LotRO INACTIVE"
		,width:1280,		height:720,		x:0,		y:0
		,bindings: KK
		,fellows:false
		,skills:false })
