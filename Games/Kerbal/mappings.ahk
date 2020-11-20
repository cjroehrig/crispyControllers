; Kerbal Space Program


#IfWinActive, ahk_exe KSP_x64.exe

; Hold brakes:
v::     AutoKey.Down("v")
v Up::  AutoKey.Up("v")

; Naga keybindings
Numpad2::		k							; Translate Up
Numpad4::		h							; Translate Left
Numpad5::		j							; Translate Down
Numpad6::		l							; Translate Right

Numpad7::		m							; Map

Numpad3::		.							; TimeWarp Increase
Numpad1::		/							; TimeWarp Stop

Numpad9::		Send,{Alt down}Q{Alt up}	; Pitch trim down
NumpadEnter::	Send,{Alt down}A{Alt up}	; Pitch trim up

Numpad0::		]							; Focus Next Vessel
NumpadDot::		z							; Precision Controls Toggle

;Numpad1::
;Numpad3::
;Numpad8::



#IfWinActive
