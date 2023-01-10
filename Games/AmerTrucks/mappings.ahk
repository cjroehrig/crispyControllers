; American Truck Simulator 
#IfWinActive, ahk_exe amtrucks.exe

; XXX: Do normal bindings in controls.sii

; Auto-Zoom
NumpadDiv::		AutoKey.Down("NumpadDiv")
NumpadDiv Up::	AutoKey.Up("NumpadDiv")
;~d::	AutoKey.Off("e"), AutoKey.Off("a")

#IfWinActive
