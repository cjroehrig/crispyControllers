;===============================================================================
; Initialization and definitions for all mappings

; AutoKey for autorun support by double-tapping
#Include Lib/ahk/AutoKey.ahk
AutoKey.Threshold := 300 	; ms

; common AHK hotkeys for all windows
#Include Lib/ahk/borderless.ahk

double_win(win)
; double the size of win (wintitle)
{
	WinGetPos, x, y, w, h, %win%
	WinMove, %win%,, x, y, w*2, h*2
	return
}
