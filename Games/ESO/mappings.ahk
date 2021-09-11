; Elder Scrolls Online

#IfWinActive, ahk_exe eso64.exe

; Autokey sprint (A)
a::		AutoKey.Down("a")
a Up::	AutoKey.Up("a")
~d::	AutoKey.Off("a")


+d::		Send h				; mount (use Send prevents Shift toggle)

; 
^PgDn::		End					; CraftStore

; Do these here (UNBOUND in-game) so I can use modifiers...
; NB: Shift doesn't seem to work...
Numpad1::	i					; Inventory
Numpad2::	u					; Character
Numpad3::	k					; Skills
Numpad4::	l					; Journal/Quest menu
Numpad6::	[					; Collections
Numpad7::	m					; map
Numpad8::	o					; Social
^Numpad8::	Send p				; Group	(NB: shift doesn't work...)
Numpad9::	Send {Backspace}=-	; UI toggle; nameplates/healthbar toggle
NumpadDot::	J					; Cycle focused quest
Numpad0::	.					; Toggle in-game cursor

; Naga keybindings
;Numpad0::,				; toggle cursor

; unbound
;Numpad5::				;
;NumpadEnter::			; chat

#IfWinActive
