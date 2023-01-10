;#IfWinActive, Grand Theft Auto V,
#IfWinActive, ahk_exe GTA5.exe
; Map Right Win to Caps Lock (for GTAV)
*RWin::			CapsLock
PrintScreen::	CapsLock

; auto-run
~3::     AutoKey.Down("e")
~3 Up::  AutoKey.Up("e")
~d::   AutoKey.Off("e")
;e::   AutoKey.Off("e")

; for infinite right...
-:: AutoKey.Down("F") AutoKey.Down("E")
- Up:: AutoKey.Up("F") AutoKey.Up("E")

; Naga
Numpad3:: Backspace
Numpad2:: Up
Numpad4:: Left
Numpad5:: Down
Numpad6:: Right
Numpad7:: Escape
Numpad9:: CapsLock


#IfWinActive
