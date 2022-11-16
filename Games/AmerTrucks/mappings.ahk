; American Truck Simulator 
#IfWinActive, ahk_exe amtrucks.exe

; XXX: Do normal bindings in controls.sii

; Auto-Zoom
NumpadDot::		AutoKey.Down("NumpadDot")
NumpadDot Up::	AutoKey.Up("NumpadDot")
;~d::	AutoKey.Off("e"), AutoKey.Off("a")

#IfWinActive
