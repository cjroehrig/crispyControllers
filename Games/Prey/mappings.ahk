; Prey (2017)

#IfWinActive, ahk_exe Prey.exe

; Auto-run
^e::		AutoKey.Down("e")
^e Up::		AutoKey.Up("e")
~d::		AutoKey.Off("e")
; Auto-run boost
;a::		AutoKey.Down("a")
;a Up::		AutoKey.Up("a")
;~d::		AutoKey.Off("e"), AutoKey.Off("a")
Tab::		AutoKey.Down("e")
^MButton::	AutoKey.Down("e")

!Numpad3::		Backspace




Numpad1::		I		; Inventory
Numpad2::		U		; Data
Numpad3::		K		; Abilities
Numpad4::		L		; Objectives

Numpad5::		G		; Use/Carry

;				Tab		; <auto run>
;				Q		; Equip Last Weapon
;				WR		; lean
;				ESDF	; move
;				T		; reload
;				Y
Numpad6::		O		; Play Audio Log
Numpad7::		M		; Map
Numpad8::		P		; Status
;				A		; sprint
;				H		; Special Use
;				J
Numpad9::		X		; Scanner Lock On
NumpadDiv::		Z		; Examine / Toggle Spectroscope
;				C		; crouch
;				V		; Flashlight
;				B
;				N
;Numpad0::
;NumpadEnter::

;=======================================
; Modifiers

^t::			6
^g::			7
^b::			8
^3::			9
^4::			0


!Numpad2::		Up		; QuickLoot Up
!Numpad5::		Down	; QuickLoot Down
!Numpad4::		Left	; QuickLoot Left
!Numpad6::		Right	; QuickLoot Right

; UI selections (Apple-style)
; NB: Wheel only sends KeyDown  events
;WheelDown::		Send {Down down}{Down up}
;WheelUp::		Send {Up down}{Up up}

; Alt-Z: toggle UI.  XXX: NOPE. not working. 
;!Z::			O
; Shift-Z: toggle UI.
;+Z::			O


#IfWinActive
