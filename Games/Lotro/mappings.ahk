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
; These functions have two modes of operation:
;	1)  SELECTED mode - if a fellowselect modifier key is held down,
;	they apply just to the selected fellow.
;	2)	default mode: 
;				follower_*		applies to self and all followers (refollow)
;					NB: for each follower, the leader will be targetted 
; 					before the hotkey is sent; the leader will be "refollowed"
;					after sending the hotkey
;				fellow_*		applies just to defaultfellow
;								(as defined in the defs-* file)

; Turn following on/off (SELECTED or all fellows)
+f::	LotroWin.Active.follow_me(true, 1000)			; follow on
+s::	LotroWin.Active.follow_me(false)				; follow off


; Sent to SELECTED or self + all followers (1s delay)
Space::					; jump
		LotroWin.Active.follower_hotkey(A_ThisHotkey, 1000)
		return

+z::	LotroWin.Active.follower_hotkey(A_ThisHotkey)		; warsteed boost

; These need special handling/nudging
^Tab::	LotroWin.Active.follower_hotkey(A_ThisHotkey,0,1)	; walk/run [nudge]
c::		LotroWin.Active.follower_hotkey(A_ThisHotkey, 200)	; warsteed stop
; give a bit of extra time for followers to stop before mounting. [no-refollow]
; no-refollow because of warsteed dismount bug
+d::	LotroWin.Active.follower_hotkey(A_ThisHotkey, 1500, 2)	; mount/unmount


; Outfits
=::						; Outfit 1: Combat
+=::					; Outfit 2: Travel
^=::					; Outfit 3: Rain
^+=::					; Outfit 4: Snow
!=::					; Outfit 5: Festival
!+=::					; Outfit 6: Relax
!^=::					; Outfit 7: 
		LotroWin.Active.follower_hotkey(A_ThisHotkey)
		return

; Target and use nearest object (SELECTED or default select fellow)
^`::	LotroWin.Active.fellow_send(KK.targetanduse)	; Ctrl-`

; SELECTed fellow movement (when Ctrl is held)
^e::	LotroWin.Active.fellow_move_start()		; Ctrl E
^e Up::	LotroWin.Active.fellow_move_stop()		; Ctrl E up


; Fellow Skills: sent to the SELECTED fellow
; NB: these will be intercepted within the current window, so you can only
; use them for remote skills.
F1::		LotroWin.Active.fellow_skill(1)			; skill 1
F2::		LotroWin.Active.fellow_skill(2)			; skill 2
F3::		LotroWin.Active.fellow_skill(3)			; skill 3
F4::		LotroWin.Active.fellow_skill(4)			; skill 4
F5::		LotroWin.Active.fellow_skill(5)			; skill 5
F6::		LotroWin.Active.fellow_skill(6)			; skill 6


; Fellow Select state
NumpadDot::		LotroWin.SetSelect(1, true)
NumpadDot Up::	LotroWin.SetSelect(1, false)
Numpad0::		LotroWin.SetSelect(2, true)
Numpad0 Up::	LotroWin.SetSelect(2, false)
; Change default fellow [= Alt + fellowselect modifiers]
!NumpadDot::	LotroWin.Active.set_defaultfellow(1)
!Numpad0::		LotroWin.Active.set_defaultfellow(2)
; Change default target (0-5) of default (or selected) fellow: 0=self
!^1::			LotroWin.Active.set_defaulttarget(0)
!^2::			LotroWin.Active.set_defaulttarget(1)
!^3::			LotroWin.Active.set_defaulttarget(2)
!^4::			LotroWin.Active.set_defaulttarget(3)
!^5::			LotroWin.Active.set_defaulttarget(4)
!^6::			LotroWin.Active.set_defaulttarget(5)


; Debugging
!p::			LotroWin.dumpAll()

#IfWinActive
