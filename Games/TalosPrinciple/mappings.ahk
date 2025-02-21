; Talos Principle

#IfWinActive, ahk_exe Talos.exe

; Auto-run
!e::		AutoKey.Down("e")
!e Up::		AutoKey.Up("e")
~d::		AutoKey.Off("e")
~Numpad5::		AutoKey.Off("e")
; Auto-run boost
;a::		AutoKey.Down("a")
;a Up::		AutoKey.Up("a")
;~d::		AutoKey.Off("e"), AutoKey.Off("a")
Tab::		AutoKey.Down("e")
MButton::	AutoKey.Down("e")

!Numpad3::		Escape

Numpad1::		Tab		; Data
Numpad2::		e
;Numpad3::		
Numpad4::		s
Numpad5::		d
Numpad6::		f
;Numpad7::
;Numpad8::
;Numpad9::
;NumpadDiv::
;Numpad0::
;NumpadEnter::


#IfWinActive
