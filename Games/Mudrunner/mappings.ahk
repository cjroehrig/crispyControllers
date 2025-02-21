; SpinTires MudRunner


#IfWinActive, ahk_exe MudRunner.exe

; Auto-run
;e::			AutoKey.Down("e")
;e Up::		AutoKey.Up("e")
MButton::	AutoKey.Toggle("e")
~d::		AutoKey.Off("e")

; Naga
Numpad1:: 		G				; Winch Pull
Numpad2:: 		A				; Differential Lock
Numpad5:: 		Q				; All wheel drive
;Numpad3:: 		
Numpad4::		M				; Map / mission
;Numpad6:: 		
Numpad7::		M				; Map / mission
;Numpad8:: 		
Numpad9::		X				; Horn
Numpad0:: 		V				; Advanced Mode
NumpadDiv::		R				; Gear Shift

#IfWinActive
