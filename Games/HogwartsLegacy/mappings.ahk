; Hogwarts Legacy

#IfWinActive, ahk_exe HogwartsLegacy.exe

; Auto-forward
;e::			AutoKey.Down("e")
;e Up::		AutoKey.Up("e")
~d::		AutoKey.Off("e"), AutoKey.Off("Space")

; Auto-forward toggle
;Tab::	 NOPE: tool-wheel
MButton::	AutoKey.Toggle("e")

; Auto-walk-fast 
+a::		AutoKey.Down("a")
+a Up::		AutoKey.Up("a")
; Auto-fly-fast 
+Space::		AutoKey.Down("Space")
+Space Up::		AutoKey.Up("Space")
; Auto-walk-slow
+c::		AutoKey.Down("c")
+c Up::		AutoKey.Up("c")


; Pause (suspend process)
!p::		Process_Suspend("HogwartsLegacy.exe")
; XXX: this can't be typed if alt-tabbed out in the meantime; --> CJRCommon
^!p::		Process_Resume("HogwartsLegacy.exe")

;+z::

;================================================================
; Naga
Numpad1::	i				; inventory
Numpad2::	u				; gear
Numpad3::	/				; challenges
Numpad4::	l				; quests
Numpad5::	j				; beast mmgt
Numpad6::	\				; collections
Numpad7::	m				; map
Numpad8::	o				; owl post
;Numpad9::
;NumpadDiv::
;Numpad0::



#IfWinActive
