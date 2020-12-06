;#IfWinActive, Grand Theft Auto V,
#IfWinActive, ahk_exe GTA5.exe
; Map Right Win to Caps Lock (for GTAV)
*RWin::		CapsLock

; for infinite right...
-:: AutoKey.Down("F") AutoKey.Down("E")
- Up:: AutoKey.Up("F") AutoKey.Up("E")


#IfWinActive
