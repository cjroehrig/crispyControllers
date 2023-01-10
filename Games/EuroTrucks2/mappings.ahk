; EuroTruckSim2:
#IfWinActive, ahk_exe eurotrucks2.exe

; XXX: Do normal bindings in controls.sii

; Auto-Zoom
NumpadDiv::		AutoKey.Down("NumpadDiv")
NumpadDiv Up::	AutoKey.Up("NumpadDiv")
;~d::	AutoKey.Off("e"), AutoKey.Off("a")

#IfWinActive
