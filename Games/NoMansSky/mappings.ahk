; No Man's Sky

#IfWinActive, ahk_exe NMS.exe

; Auto-run
e::		AutoKey.Down("e")
e Up::	AutoKey.Up("e")
;~d::	AutoKey.Off("e")
; Auto-run boost
a::		AutoKey.Down("a")
a Up::	AutoKey.Up("a")
~d::	AutoKey.Off("e"), AutoKey.Off("a")

; Naga keybindings - general
Numpad1::Tab			; Inventory
Numpad4::p				; Log/Quest menu
Numpad6::,				; Previous Target
Numpad7::m				; map

; Naga keybindings - ESDF
Numpad2::x				; Quick menu
Numpad3::z				; Build menu
Numpad5::c				; Scan
Numpad9::v				; Next Target
NumpadDot::LCtrl		; Free Look

; Naga keybindings - WASD
;Numpad2::z				; Quick menu
;Numpad3::LShift			; Build menu
;Numpad5::x				; Scan
;Numpad9::c				; Next Target
;NumpadDot::LAlt			; Free Look

; unbound
;Numpad8::
;Numpad0::
;NumpadEnter::

#IfWinActive
