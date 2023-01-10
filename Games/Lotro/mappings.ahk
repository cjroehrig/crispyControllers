; Common LotRO hotkey definitions
#IfWinActive, ahk_exe lotroclient64.exe

; AutoHotKey convention:
;		!		Alt
;		^		Ctrl
;		+		Shift

; 	## USED bindings
;	^!NumpadDot		- == Ctrl-Alt-Delete ! 
;	^!g				- Xbox GameBar
;	^!r				- XBox GameBar record
;	^!t				- XBox GameBar stop record last 30 seconds
;	!NumpadDiv, !Numpad0, !NumpadEnter	- VLC <<, ||, >>   UGH
;	## Lotro in-game Alt- bindings
;	!r				- Radar on/off
;	!f				- Find items
;	!v				- Show names
;	!d				- Show damage
;	!h				- Detach tooltip
;	!/  !.			- Screenshot
;	!z				- Toggle HUD
;	!x				- Item lock
;	!m				- Music mode
;	!1-9,0			- Fellowship target marking
;	!=,etc			- Outfits
;	!c				- show FPS
;	AVAILABLE HERE:		qwe..yuiop as....jkl; ....bn.

!e::LotroWin.RotateName()			; Rotate window name/title
^!e::LotroWin.Reset()				; Remove all fellows
+!e::LotroWin.ResetRoles()			; Reset all window's roles
!w::LotroWin.RotateParty(1)			; Rotate party order
^!w::LotroWin.RotateParty(10)		; Fast-forward rotate party order

;==============================================================================
; Window layout & position
!a::		LotroWin.LayoutWindowed()			; Alt A		layout windowed
!q::		LotroWin.LayoutFullScreen()			; Alt Q		layout fullscreen

;==============================================================================
; FOLLOWING 
; These functions have two modes of operation:
;	1)  SELECTED mode - if a fellowselect modifier key is held down,
;	they apply just to the SELECTed fellow.
;	2)	default mode: 
;				FollowerHotkey():	applies to self and all followers (refollow)
;					NB: for each follower, the leader will be targetted 
; 					before the hotkey is sent; the leader will be "refollowed"
;					after sending the hotkey.
;					It has optional parameters for delay (ms) and flags
;					flags:
;						1	nudge before refollowing
;						2	do not refollow
;					NB: this takes a hotkey parameter in hotkey format, 
;					not Send format.
;				fellow_*()		applies just to defaultfellow

; Turn following on/off (SELECTED or all fellows)
+f::	LotroWin.Active.follow_me(true, 1000)			; follow on
+s::	LotroWin.Active.follow_me(false)				; follow off


; Sent to SELECTED or self + all followers (1s delay)
Space::					; jump
		LotroWin.FollowerHotkey(A_ThisHotkey, 1000)
		return

+z::	LotroWin.FollowerHotkey(A_ThisHotkey)		; warsteed boost

; These need special handling/nudging
^Tab::	LotroWin.FollowerHotkey(A_ThisHotkey,0,1)	; walk/run [nudge]
c::		LotroWin.FollowerHotkey(A_ThisHotkey, 200)	; warsteed stop
; give a bit of extra time for followers to stop before mounting. [no-refollow]
; no-refollow because of warsteed dismount bug
+d::	LotroWin.FollowerHotkey(A_ThisHotkey, 1500, 2)	; mount/unmount


; Outfits
=::						; Outfit 1: Combat
+=::					; Outfit 2: Travel
^=::					; Outfit 3: Rain
^+=::					; Outfit 4: Snow
!=::					; Outfit 5: Festival
!+=::					; Outfit 6: Relax
!^=::					; Outfit 7: 
		LotroWin.FollowerHotkey(A_ThisHotkey)
		return

; Target and use nearest object (SELECTED or defaultfellow) - Ctrl-backquote
; NB: fellow_send takes a string in Send format, not hotkey format.
^`::	LotroWin.Active.fellow_send("{Shift down}VC{Shift up}")

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


; Fellow Select state (hold to use as a shift-type modifier)
NumpadDiv::		
	Critical
	LotroWin.SetSelect(1, true)
	return
*NumpadDiv Up::	
	Critical
	LotroWin.SetSelect(1, false)
	return
Numpad0::		
	Critical
	LotroWin.SetSelect(2, true)
	return
*Numpad0 Up::	
	Critical
	LotroWin.SetSelect(2, false)
	return

; Change default fellow [= Ctrl-Alt + fellowselect modifiers]
!^NumpadDiv::	LotroWin.Active.set_defaultfellow(1)
!^Numpad0::		LotroWin.Active.set_defaultfellow(2)

; Change the target (0-5) of default (or selected) fellow: 0=self
; NB: 	^!NumpadDot is Ctrl-Alt-Delete! so holding NumpadDot won't work here:
!^1::			LotroWin.Active.set_remotetarget(0)
!^2::			LotroWin.Active.set_remotetarget(1)
!^3::			LotroWin.Active.set_remotetarget(2)
!^4::			LotroWin.Active.set_remotetarget(3)
!^5::			LotroWin.Active.set_remotetarget(4)
!^6::			LotroWin.Active.set_remotetarget(5)


; Debugging
!p::			LotroWin.DumpAll()

#IfWinActive
