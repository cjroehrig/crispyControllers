; XXX: watch out for this...
^!p::	
		Process_Resume("KingdomCome.exe")
		Process_Resume("HogwartsLegacy.exe")
		return
;===============================================================================
; CJR's Common Hotkey definitions -- active for all windows/programs

; Right-Alt + Middle mouse == window always on top
>!MButton:: Winset, Alwaysontop,, A

; Right-Alt + F == Borderless fullscreen
>!F::ToggleFakeFullscreen()

; Right-Alt --> Insert (Win10 Narrator)
; NOPE: doesn't work
;RAlt:: Insert

; Map Left Win to Ctrl (except for VNC windows)
#IfWinNotActive, ahk_group VNCWindows
*LWin::		Send {LControl Down}
*LWin Up::	Send {LControl Up}
#IfWinNotActive


;=====================================================================
; Media Keys to VLC, Calibre
; 	Logitech:  F8/F9/F10
;	Razor Naga Alt-bottom row Numpad Div/0/Enter
; XXX:  Calibre (7.4) has no TTS hotkey support yet...

; BACK
+F8::
!NumpadDiv::
	ControlSend, , {Alt down}{Left}{Alt up},	ahk_exe vlc.exe
;	ControlSend, , {Alt down}{Left}{Alt up},	ahk_exe calibre-parallel.exe
	return

; PAUSE/PLAY
+F9::
!Numpad0::
	ControlSend, , {space},						ahk_exe vlc.exe
	return

; FWD
+F10::
!NumpadEnter::
	ControlSend, , {Alt down}{Right}{Alt up},	ahk_exe vlc.exe
	return

;=====================================================================


; XXX: doesn't work.  Calibre/Qt doesn't seem to respond the same way...
;  Research AutoHotKey + Qt
; Alt-numpad0: play/pause Calibre TTS:
;#IfWinNotActive, ahk_exe calibre-parallel.exe,
;!Numpad0:: 	ControlSend, , {Alt down}{Numpad0}{Alt up}, ahk_exe calibre-parallel.exe
;#IfWinNotActive


; Alt-p:  Double window size of active window
; XXX: doesn't work on BigFish windows -- window doubles, but content doesn't.
;!p::double_win("A")

