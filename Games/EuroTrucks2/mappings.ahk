; EuroTruckSim2:
#IfWinActive, ahk_exe eurotrucks2.exe

; XXX: Do normal bindings in controls.sii

; Auto-Zoom
NumpadDot::		AutoKey.Down("NumpadDot")
NumpadDot Up::	AutoKey.Up("NumpadDot")
;~d::	AutoKey.Off("e"), AutoKey.Off("a")

#IfWinActive
