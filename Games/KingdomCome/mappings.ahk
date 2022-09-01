; Kingdom Come Deliverance

#IfWinActive, ahk_exe KingdomCome.exe

; Auto-run
^e::		AutoKey.Down("e")
^e Up::		AutoKey.Up("e")
~d::		AutoKey.Off("e")
; Auto-run boost
;a::		AutoKey.Down("a")
;a Up::		AutoKey.Up("a")
;~d::		AutoKey.Off("e"), AutoKey.Off("a")
Tab::		AutoKey.Down("e")
MButton::	AutoKey.Down("e")


; Pause (suspend process)
!p::		Process_Suspend("KingdomCome.exe")
; XXX: this can't be typed if alt-tabbed out in the meantime; --> CJRCommon
^!p::		Process_Resume("KingdomCome.exe")

; 
;+z::
z::
	global kcd_ui
	if ( kcd_ui ) {
		SendInput '0'
		kcd_ui := false
	} else {
		SendInput '9'
		kcd_ui := true
	}
	return

#IfWinActive
