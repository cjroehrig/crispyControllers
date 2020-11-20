; EuroTruckSim2:
#IfWinActive, ahk_exe eurotrucks2.exe

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
