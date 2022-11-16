; Lotro bindings (other than hotkeys)

;==============================================================================
; Key bindings (with global name KK)
KK := {_:0

	,forward		: "e"								; move forward
	,follow			: "+{Tab}" 							; follow target
	,steedhalt		: "c"								; warsteed halt
	,targetanduse	: "{Shift down}VC{Shift up}"		; target object & use

	; keys to target/assist fellows 1-6  (1 == self)
	; These are as you have defined them within LotRO itself.
	; NB: ^ == Control; + == Shift; ! == Alt 
	,target 		: [  "^{F1}", "^{F2}", "^{F3}"
						,"^{F4}", "^{F5}", "^{F6}" ]
	,assist 		: [  "+{F1}", "+{F2}", "+{F3}"
						,"+{F4}", "+{F5}", "+{F6}" ]

	; keys for remote-use skills.
	; You can have more (or fewer) than 6, but they must be matched 
	; in skilltarget and skillassist arrays in your defs-* files.
	; NB: these keys should also have hotkey definitions in mappings.ahk 
	,skills 		: [  "{F1}", "{F2}", "{F3}"
						,"{F4}", "{F5}", "{F6}" ]

	,_:0}

