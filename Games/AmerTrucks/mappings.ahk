; American Truck Simulator 
#IfWinActive, ahk_exe amtrucks.exe

; Windows
^Numpad1::		.		; Left close
^Numpad4::		,		; Left open
^Numpad2::		:		; Right close
^Numpad5::		/		; Right open

; Auto-Zoom
NumpadDot::		AutoKey.Down("NumpadDot")
NumpadDot Up::	AutoKey.Up("NumpadDot")
;~d::	AutoKey.Off("e"), AutoKey.Off("a")

#IfWinActive
