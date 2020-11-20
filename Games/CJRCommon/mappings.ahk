;===============================================================================
; CJR's Common Hotkey definitions -- active for all windows/programs

; Right-Alt + Middle mouse == window always on top
>!MButton:: Winset, Alwaysontop,, A

; Right-Alt + F == Borderless fullscreen
>!F::ToggleFakeFullscreen()

; Right-Alt --> Insert (Win10 Narrator)
; NOPE: doesn't work
;RAlt:: Insert

; Map Left Win to Ctrl (except for tringa VNC)
#IfWinNotActive, tringa,
*LWin::		Send {LControl Down}
*LWin Up::	Send {LControl Up}
#IfWinNotActive


; Media Keys to VLC
; (shift-F7-F9)
+F7::			ControlSend, , {Alt down}{Left}{Alt up},	ahk_exe vlc.exe
+F8::			ControlSend, , {space},						ahk_exe vlc.exe
+F9::			ControlSend, , {Alt down}{Right}{Alt up},	ahk_exe vlc.exe
; Razor Naga Alt-bottom row
; (~ == Pass through)
!NumpadDot::	ControlSend, , {Alt down}{Left}{Alt up},	ahk_exe vlc.exe
!Numpad0::		ControlSend, , {space},						ahk_exe vlc.exe
!NumpadEnter::	ControlSend, , {Alt down}{Right}{Alt up},	ahk_exe vlc.exe


; XXX: doesn't work.  Calibre/Qt doesn't seem to respond the same way...
;  Research AutoHotKey + Qt
; Alt-numpad0: play/pause Calibre TTS:
;#IfWinNotActive, ahk_exe calibre-parallel.exe,
;!Numpad0:: 	ControlSend, , {Alt down}{Numpad0}{Alt up}, ahk_exe calibre-parallel.exe
;#IfWinNotActive


; Alt-p:  Double window size of active window
; XXX: doesn't work on BigFish windows -- window doubles, but content doesn't.
;!p::double_win("A")

