#IfWinActive, ahk_exe TS2Prototype-WinGDK-Shipping.exe

; auto-run
MButton::
	if (TSW3_autorun) {
		Send {e Up}
	} else {
		Send {e Down}
	}
	TSW3_autorun := !TSW3_autorun
	return


; NB: modifiers don't seem to work when sending to TSW3
; --> can only map to base keys

; See TrainSim/Controls.txt
; Naga
; Dynamic Brakes:   . ,
Numpad1:: 	.
^Numpad1:: 	,
; Independent (Locomotive) Brakes: ] [
Numpad2:: 	]
^Numpad2:: 	[
; Automatic (Train) Brakes: ' ;
Numpad3:: 	'
^Numpad3:: 	`;
Numpad5:: 	Backspace
PgUp::		\
;PgDn::		+\			No, just hold shift when pressing PgUp

Numpad4::	7
Numpad7:: 	9
Numpad0:: 	0

; !z::		F1

;Numpad3:: 
;Numpad6:: 
;Numpad8:: 			# bound in-game
;Numpad9:: 			# bound in-game
;NumpadDiv::


#IfWinActive
