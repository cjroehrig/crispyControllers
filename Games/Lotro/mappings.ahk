; Common LotRO hotkey definitions
#IfWinActive, ahk_exe lotroclient64.exe

; Rotate window title
!w::RotateWinTitle( LotroWin.Windows
	,["^The Lord of the Rings Online*", "^LotRO *"] )

;==============================================================================
; Window layout & position
!a::		LotroWin.layout_win()			; Alt A		layout windowed
!q::		LotroWin.layout_full()			; Alt Q		layout fullscreen

;==============================================================================
; FOLLOWING 

; FOLLOW ON
+f::	LotroWin.Active.follow_on_all(true)				; all fellows
!+f::	LotroWin.Active.follow_on(true)					; just selected
; FOLLOW OFF
+s::	LotroWin.Active.follow_on_all(false)			; all fellows
!+s::	LotroWin.Active.follow_on(false)				; just selected


; FOLLOWing keys -- sent to active window and all its followers
; (after the default delay)
+d::	LotroWin.Active.send_following("+d",,2)			; mount/unmount
Space::	LotroWin.Active.send_following("{Space}")		; jump
^Tab::	LotroWin.Active.send_following("^{Tab}",,1)		; walk/run
c::		LotroWin.Active.send_following("c", 200)		; warsteed stop
+z::	LotroWin.Active.send_following("+z")			; warsteed boost

; Outfits
=::		LotroWin.Active.send_following("=")				; Outfit 1
+=::	LotroWin.Active.send_following("+=")			; Outfit 2
^=::	LotroWin.Active.send_following("^=")			; Outfit 3
!=::	LotroWin.Active.send_following("!=")			; Outfit 4
^+=::	LotroWin.Active.send_following("^+=")			; Outfit 5
!+=::	LotroWin.Active.send_following("!+=")			; Outfit 6
!^=::	LotroWin.Active.send_following("!^=")			; Outfit 7


;==============================================================================
; Fellow keys -- sent to the Active window's selected Fellow

; Fellow SELECT: choose which fellow (1-5)
NumpadDot::		LotroWin.Active.fellow_select(1)		; select first fellow
Numpad0::		LotroWin.Active.fellow_select(2)		; select second fellow

; Fellow Skills: sent to the SELECTed fellow
F1::		LotroWin.Active.fellow_skill(1)			; skill 1
F2::		LotroWin.Active.fellow_skill(2)			; skill 2
F3::		LotroWin.Active.fellow_skill(3)			; skill 3
F4::		LotroWin.Active.fellow_skill(4)			; skill 4
F5::		LotroWin.Active.fellow_skill(5)			; skill 5
F6::		LotroWin.Active.fellow_skill(6)			; skill 6

; SELECTed Fellow: Target and use nearest object
^`::		LotroWin.Active.fellow_send(KK.targetanduse)	; Ctrl-`

; SELECTed fellow movement (when Ctrl is held)
^e::	LotroWin.Active.fellow_move_start()		; Ctrl E
^e Up::		LotroWin.Active.fellow_move_stop()		; Ctrl E up

#IfWinActive
