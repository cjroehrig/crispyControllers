;===============================================================================
; Initialization and definitions for all mappings

; AutoKey for autorun support by double-tapping
#Include Lib/ahk/AutoKey.ahk
AutoKey.Threshold := 300 	; ms

#Include Lib/ahk/borderless.ahk

; For KingdomCome
#Include Lib/ahk/Process.ahk


double_win(win)
; double the size of win (wintitle)
{
	WinGetPos, x, y, w, h, %win%
	WinMove, %win%,, x, y, w*2, h*2
	return
}

;=======================================
; Window Groups

; VNC windows
; NB: title matching is done by SetTitleMatchMode
GroupAdd, VNCWindows, tringa ahk_exe vncviewer.exe
GroupAdd, VNCWindows, calypte ahk_exe vncviewer.exe
GroupAdd, VNCWindows, pipilo ahk_exe vncviewer.exe
GroupAdd, VNCWindows, tyto ahk_exe vncviewer.exe
