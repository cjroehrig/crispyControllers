; Lotro bindings (other than hotkeys)

;==============================================================================
; Key bindings (with global name KK)
KK := {_:0

	,forward		: "e"								; move forward
	,follow			: "+{Tab}" 							; follow target
	,steedhalt		: "c"								; warsteed halt
	,targetanduse	: "{Shift down}VC{Shift up}"		; target object & use

	; keys to target/assist fellows 1-6  (1 == self)
	,target 		: [  "^{F1}", "^{F2}", "^{F3}"
						,"^{F4}", "^{F5}", "^{F6}" ]
	,assist 		: [  "+{F1}", "+{F2}", "+{F3}"
						,"+{F4}", "+{F5}", "+{F6}" ]

	,_:0}

