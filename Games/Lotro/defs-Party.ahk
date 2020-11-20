; CJRParty Lotro setup for 2-boxing (dps/heal) with a full party

;===============================================================================
; Window (and fellowship) definitions

; Windowed: 1280x720
; fellows: array of titles of fellow windows in fellowship order.
; skills: array of skill keys to be controlled by other fellows.
;    ^Ctrl == target;   +Shift == assist  F1-F6 is fellow member (F1=self)
;
;		MAIN=DPS;  AUX=Healer;		TERTIARY=Tank
;	# 			self		N=1			N=2
;	# window	F1			F2			F3			F4			F5
;	MAIN		Daer		Mel			Boph		Vehr		Germ
;	AUX			Mel			Daer		Boph		Vehr		Germ
;
; MAIN -- DPS
new LotroWin( {title: "LotRO MAIN"		
		,width:1280,		height:720,		x:0,		y:322
		,bindings: KK
		,fellows:["LotRO AUX"]
		,select: 1			; Daer -> Mel
		; DPS: Assist Germ (Shift F5)
		,skills:[	 "+{F5}{F1}"
					,"+{F5}{F2}"
					,"+{F5}{F3}"
					,"+{F5}{F4}"
					,"+{F5}{F5}"
					,"+{F5}{F6}" ]})

; AUX -- Healer
new LotroWin( {title: "LotRO AUX"
		,width:1280,		height:720,		x:624,		y:0
		,bindings: KK
		,fellows:["LotRO MAIN"]
		,select: 1			; Mel -> Daer
		; Healer: Target Boph (Tank) (Ctrl F3)
		,skills:[	 "^{F3}{F1}"
					,"^{F3}{F2}"
					,"^{F3}{F3}"
					,"^{F3}{F4}"
					,"^{F3}{F5}"
					,"^{F3}{F6}" ]})


; INACTIVE
new LotroWin( {title: "LotRO INACTIVE"
		,width:1280,		height:720,		x:0,		y:0
		,bindings: KK
		,fellows:false
		,select:false
		,skills:false })
