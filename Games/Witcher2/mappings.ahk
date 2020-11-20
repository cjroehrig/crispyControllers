; Witcher2
#IfWinActive, ahk_exe witcher2.exe


Numpad1::		I		; Inventory
Numpad2::		C		; Character
Numpad3::		Tab		; Tutorials

Numpad4::		J		; Journal
;Numpad5::
;Numpad6::

Numpad7::		M		; Map
Numpad8::		O		; toggle HUD
;Numpad9::		

NumpadDot::		Escape	; :/
Numpad0::		Y		; Next quickslot
NumpadEnter::	Enter	; :/

; UI selections (Apple-style)
; NB: Wheel only sends KeyDown  events
WheelDown::		Send {Down down}{Down up}
WheelUp::		Send {Up down}{Up up}

; Alt-Z: toggle UI.  XXX: NOPE. not working. 
;!Z::O
; Shift-Z: toggle UI.
+Z::			O

#IfWinActive
