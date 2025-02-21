; The Last of Us Part 1

#IfWinActive, ahk_exe tlou-i.exe

; Weapon Cross
;		SLOT	WEAPON						CJR
;		1		Holstered Long Gun			5
;		2		Long Gun					4
;		3		Short Gun					3
;		4		Hostered Short Gun			2
;		5		Bomb						Ctrl-B
;		6		Smoke Bomb					Ctrl-
;		7		Health Kit					H
;		8		Brick/Bottle				1
;		9		Molotov Cocktail			

1::		Return
5::		Return
6::		Return
7::		Return
8::		Return
9::		Return
^4::	1		; 1: Holstered Long Gun			Ctrl-4
4::		2		; 2: Long Gun					4
3::		3		; 3: Short Gun					3
^3::	4		; 4: Hostered Short Gun			Ctrl-3
^b::	5		; 5: Bomb						Ctrl-B
+^b::	6		; 6: Smoke Bomb					Shift-Ctrl-B
h::		7		; 7: Health Kit					H
2::		8		; 8: Brick/Bottle				2
^r::	9		; 9: Molotov Cocktail			Ctrl-R

^v::	J		; Shake flashlight


; extra Naga keybindings
Numpad3::		Backspace						; BACK
Numpad1::		Tab								; Skill/crafting

Numpad2::		Up
Numpad4::		Left
Numpad5::		Down
Numpad6::		Right


#IfWinActive
