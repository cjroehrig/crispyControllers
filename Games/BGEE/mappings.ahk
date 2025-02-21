
; Baldur's Gate Enhanced Edition

; NOTES:
;	- ^(Ctrl) versions need to use Send {...} to suppress Ctrl passthrough
;	  (BGEE uses Ctrl for Console/Debug hotkeys :/)
;	- Some ! also need Send {...} syntax
;	- Shift weirdness: appears to prevent hotkey blocking (Numpad1-9); avoid?

#IfWinActive, ahk_exe Baldur.exe

; Swap Mouse buttons
;lbutton::	rbutton
;rbutton::	mbutton
;mbutton::	lbutton

;================================================================
; Naga
; NB: need to override BG's hardcoded direction numpad with null assigns
Numpad1::		Send {1}		; Character 1
Numpad2::		Send {2}		; Character 2
Numpad3::		Send {3}		; Character 3
Numpad4::		Send {4}		; Character 4
Numpad5::		Send {5}		; Character 5
Numpad6::		Send {6}		; Character 6
Numpad7::		Send {7}		; Characters 1,2
Numpad8::		Send {8}		; Characters 3,4
Numpad9::		Send {9}		; Characters 5,6
NumpadDiv::		Send {-}		; Characters 1,2,3
Numpad0::		Send {=}		; Characters 4,5,6
NumpadEnter::	Enter

; -------- Ctrl
^Numpad1::		Send {i}		; Inventory
^Numpad2::		Send {u}		; Character sheet
^Numpad3::		Send {o}		; Mage Spells
^Numpad4::		Send {l}		; Quests/Journal
^Numpad5::		return
^Numpad6::		Send {p}		; Priest Spells
^Numpad7::		Send {m}		; Map
^Numpad8::		return
^Numpad9::		return
^NumpadDiv::	Send {.}		; Quick Loot
^Numpad0::		/				; Hard Pause
;^NumpadEnter::	return
; -------- Alt
!Numpad1::		return
!Numpad2::		\				; Quicksave
!Numpad3::		return
!Numpad4::		return
!Numpad5::		return
!Numpad6::		return
!Numpad7::		return
!Numpad8::		return
!Numpad9::		return
!NumpadDiv::	Send {,}		; Hide UI
; -------- Shift
; BLOCKING DOESN'T WORK
; NB: Shift down seems to prevents Num* blocking and passes it through :(


;================================================================
; Hotkeys

;=================================
; Character Select
; Swap 1-9,0-=  <--> F1-12
F1::			1
F2::			2
F3::			3
F4::			4
F5::			5
F6::			6
F7::			7
F8::			8
F9::			9
F10::			0
F11::			-
F12::			=

;=================================
; Hotbar:  my usual layout (mostly)
1::				F1			; Dialog
2::				F2			; Weapon Slot 1
3::				F3			; Weapon Slot 2 / Group Stop
4::				F4			; Weapon 3 / Spell 1 / Trap Det. / Turn Undead
5::				F5			; Weapon 4 / Spell 2 / Thieving / Guard
6::				F6			; Spell 3 / Stealth
t::				F7			; Cast Spell
g::				F8			; Use Item
y::				F9			; Item 1
h::				F10			; Item 2
n::				F11			; Item 3
b::				F12			; Special Abilities

;=================================
; Duplicate actions
^s::			Send {F5}		; Stealth
^e::			Send {F2}		; Group Attack
^d::			Send {F3}		; Group Stop

;=================================
; MISC
!z::			-				; Hide UI
;F5::			P				; Quick Save
^a::			Send {0}		; Select All






#IfWinActive
