; AutoKey
;
; - Auto-holds the key down (e.g. autorun) when pressed twice rapidly.
; - Pressing again releases it. Can also assign other keys to release it.
; - XXX: only works for simple keys, not key combinations.
; 
; Usage:
;	#Include AutoKey.ahk
;	AutoKey.Threshold = 300			; set threshold for auto-hold (ms)
;   w    :: AutoKey.Down("w")		; assign Down action for 'w'
;   w Up :: AutoKey.Up("w")			; assign Up action for 'w'
;   ~s   :: AutoKey.Off("w")		; 's' functions as an off for "w"

;===============================================================================
class AutoKey {
	; An object to hold the autoOn state for a key, as well
	; as the Class methods to implement the functionality.
	static Threshold	:= 300		; milliseconds
	static keyStates 	:= {}		; associative array of AutoKey objects

	key					:= ""		; the key for which this is the state.
	autoOn				:= false	; auto-on state
	lastEv				:= 0		; time since last key event (ms)
	lastUp				:= 0		; time since last key Up event (ms)
	;lastDown			:= 0		; time since last key Down event (ms)

	;==========================================================================
	; CLASS METHODS

	;=======================================
	Up(key)
	;  Handle a key Up event. 'key' is a string of the key name (e.g. 'w').
	{
		key_state := AutoKey.Get(key)
		key_state.keyUp()
	}

	;=======================================
	Down(key)
	;  Handle a key Down event. 'key' is a string of the key name (e.g. 'w').
	{
		key_state := AutoKey.Get(key)
		key_state.keyDown()
	}
	;=======================================
	Off(key)
	;  Turn off auto for 'key'. Typically bound to another key.
	{
		key_state := AutoKey.Get(key)
		key_state.keyOff()
	}

	;=======================================
	Toggle(key)
	;  Toggle auto for 'key'. 'key' is a string of the key name (e.g. 'w').
	{
		key_state := AutoKey.Get(key)
		key_state.keyToggle()
	}


	;=======================================
	Get(key)
	; CLASS METHOD: Return a AutoKey object for key.
	{
		if ( AutoKey.keyStates.HasKey(key) ) {
			key_state := AutoKey.keyStates[key]
		} else {
			key_state := new AutoKey(key)
			AutoKey.keyStates[key] := key_state
		}
		return key_state
	}

	;==========================================================================
	; INSTANCE METHODS

	;=======================================
	__New(key)
	; Return a new AutoKey object for a specific key.
	{
		this.key := key
		this.autoOn := false
		this.lastEv := A_TickCount
		this.lastUp := 0
		Dbg("AUTOKEY: New({})", key)
		return this
	}

	keyUp()
	; Release key if is not auto'd.
	{
		t := A_TickCount
		if ( !this.autoOn ){
			seq := "{" . this.key . " Up}"
			Dbg("AUTOKEY({}) UP      dt={:.3f}",this.key, (t-this.lastEv)/1000)
			Send, %seq%
		} else {
			Dbg("AUTOKEY({}) UP-ign  dt={:.3f}",this.key, (t-this.lastEv)/1000)
		}
		this.lastEv := t
		this.lastUp := t
	}

	keyOff()
	; Turn off auto.
	{
		t := A_TickCount
		seq := "{" . this.key . " Up}"
		Send, %seq%
		Dbg("AUTOKEY({}) AUTO-X  dt={:.3f}",this.key, (t-this.lastEv)/1000)
		this.autoOn := false
		this.lastEv := t
	}

	keyOn()
	; turn auto on for key
	{
		t := A_TickCount
		seq := "{" . this.key . " Down}"
		Send, %seq%
		Dbg("AUTOKEY({}) AUTO-ON", this.key )
		this.autoOn := true
		this.lastEv := t
	}

	keyDown()
	; Press the key and figure out if it should be auto'd.
	{
		t := A_TickCount
		Dbg("AUTOKEY({}) DOWN    dt={:.3f}",this.key, (t-this.lastEv)/1000)
		if (this.autoOn) {
			; already auto'd; terminate auto
			this.autoOn := false
			Dbg("AUTOKEY({}) AUTOOFF dt={:.3f}",this.key, (t-this.lastEv)/1000)
		} else if ( (t - this.lastUp) < AutoKey.threshold ){
			; pressed again within threshhold; go to auto
			this.autoOn := true
			Dbg("AUTOKEY({}) AUTO-ON dt={:.3f}",this.key, (t-this.lastEv)/1000)
		}
		this.lastEv := t
		seq := "{" . this.key . " Down}"
		Send, %seq%
	}

	keyToggle()
	; Toggle the state of key.
	{
		if ( this.autoOn ){
			this.KeyOff()
		} else {
			this.KeyOn()
		}
	}

}
