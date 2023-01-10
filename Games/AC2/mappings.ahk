; Assassin's Creed II

; AC2 menus don't work if RMB is bound to GRAB/HAND
; so bind it to MMB instead and map it here.

#IfWinActive, ahk_exe AssassinsCreedIIGame.exe


RButton::MButton		; RMB -> MMB

; Naga keybindings
Numpad1::Space			; Menu Select  LEGS
Numpad5::Space			; Menu Select  LEGS
Numpad2::G				; HEAD
Numpad4::Esc			; Menu
Numpad7::Tab			; Map / Menu Exit All
NumpadDiv::B			; Contextual Camera
Numpad0::Z				; FP Camera
---
Numpad3::2				; Hidden Blade
Numpad6::3				; Sword
Numpad9::1				; Medicine
---

#IfWinActive
