; LotRO Window object

; A LotRO window represents a character/toon in a fellowship
; with assorted methods to take actions within the fellowship.

;#Include util.ahk
;#Include io.ahk

WinVersion := DllCall("GetVersion") & 0xFF
if ( WinVersion == 10 ) {
	Dbg("Windows 10")
	WinBorderX := 8 + 8	
	WinBorderY := 8 + 30 + 1		; beats me
} else {
	Dbg("Windows 7")
	WinBorderX := 8 + 8	
	WinBorderY := 8 + 30
}



class LotroWin {

	;==========================================================================
	; Class properties
	static Windows := []		; the list of all defined window objects

	;==========================================================================
	; Instance Properties
	; These should be filled in by passing a corresponding dictionary object
	; to the constructor.
	title	:= ""		; The window title

	; Windowed: 1280x720
	width	:= 1280		; width
	height	:= 720		; height
	x		:= 0		; x,y position (top-left-based)
	y		:= 0		; 

	fellows	:= false	; array of window titles of fellows (in order)
	skills	:= false	; array of skill key strings for this window
	select	:= false	; default fellow selection (at startup)

	; default delay before sending keystrokes to following windows (ms)
	follow_delay := 1000

	; dictionary of key bindings (as an example of required bindings)
	bindings := 	{_:0
		,forward		: "e"							; move forward
		,follow			: "+{Tab}" 						; follow target
		; keys to target/assist fellows 1-6  (1 == self)
		,target 		: [  "^{F1}", "^{F2}", "^{F3}"
							,"^{F4}", "^{F5}", "^{F6}" ]
		,assist 		: [  "+{F1}", "+{F2}", "+{F3}"
							,"+{F4}", "+{F5}", "+{F6}" ]
		,_:0}


	;========================================
	; Internal instance variables
	; State
	_following		:= false	; the object being followed
	_fellows		:= false	; array of LotroWins corresponding to fellows
	_selected		:= false	; currently selected fellow (a LotroWin object)
	_moving			:= false	; true if this window is "fellow_moving"


	;==========================================================================
	; Class Methods

	;========================================
	; Active is a read-only class property that returns the LotroWin object
	; with the current active window.
	Active[] {
		get {
			return LotroWin.getwin(GetActiveTitle())
		}
		set {
		}
	}

	;========================================
	finalize()
	; Class method to get all windows ready.
	; Fills in each win._fellows with an array of LotroWin objects
	; corresponding to its fellows array.
	{
		for k, win in LotroWin.Windows {
			; set up array of fellow object
			if (win.fellows) {
				win._fellows := []
				for k, title in win.fellows {
					f := LotroWin.getwin(title)
					if ( f ) {
						win._fellows.Push(f)
					} else {
						Dbg("WARNING: finalize ({}): no fellow window "
								. "named '{}' found.", win.title, title )
						win._fellows.Push(false)
					}
				}
			}
		}
		; set up default fellow selection
		for k, win in LotroWin.Windows {
			if (win.select) {
				win.fellow_select(win.select)
			}
		}
	}

	;========================================
	getwin(title)
	; Class method to return the window with given title
	{
		for k, win in LotroWin.Windows {
			if ( win.title == title ) {
				return win
			}
		}
		Dbg("WARNING: no such fellow window: {}", title )
		return false
	}

	;========================================
	layout_win()
	; Class method to layout all windows in windowed mode.
	{
		global WinBorderX, WinBorderY
		active := LotroWin.Active
		for k, w in LotroWin.Windows {
			title := w.title
			WinGetPos, x, y, width, height, %title%
			Dbg("BEFORE: {}: {}x{} @ {},{}", w.title, width, height, x, y )
			x := w.x
			y := w.y
			width := w.width + WinBorderX
			height := w.height + WinBorderY
			MoveWin( w.title, x, y, width, height )
			WinGetPos, x, y, width, height, %title%
			Dbg("AFTER:  {}: {}x{} @ {},{}", w.title, width, height, x, y )
			if ( w.title == active.title ) {
				SendChat("", "/ui layout load w{Enter}")
			} else {
				SendChat(w.title, "/ui layout load wbg{Enter}")
			}
		}
		return
	}

	;========================================
	layout_full()
	; Class method to layout all windows with Active in fullscreen
	{
		global FullScreen
		active := LotroWin.Active
		MoveWin( "A", 0, 0, FullScreen.width, FullScreen.height )
		for k, w in LotroWin.Windows {
			if ( w.title == active.title ) {
				SendChat("", "/ui layout load f{Enter}")
			} else {
				SendChat(w.title, "/ui layout load wbg{Enter}")
			}
		}
		return
	}

	;========================================
	dumpAll()
	; dump our class
	{
		Dbg("=================================================")
		Dbg("DUMP: LotroWin.Windows (Length={}):", LotroWin.Windows.Length())
		for k, win in LotroWin.Windows {
			win.dump()
		}
	}

	;==========================================================================
	; Instance Methods

	;========================================
	__New(settings)
	; CONSTRUCTOR: Initialize this object with a dictionary of settings,
	; and add it to the class window list.
	{
		;Dbg( "LotroWin::__New()" )
		for key, value in settings {
			;Dbg( "  [{}] <-- {}", key, value )
			this[key] := value
		}
		LotroWin.Windows.Push(this)
		return this
	}

	;========================================
	follow_on_all(on:=true)
	; Turn following on/off for all fellows.
	{
		for k, win in LotroWin.Windows {
			if ( win._fellows && win != this ){
				this._follow_on(win, on)
			}
		}
	}

	;========================================
	follow_on(on:=true)
	; Turn following on/off for the selected fellow.
	{
		if (this._selected) {
			this._follow_on(this._selected, on)
		}
	}

	;========================================
	_follow_on(fellow, on:=true)
	; Turn following on/off for fellow.
	{
		if ( fellow && fellow != this ){
			if (on) {
				; Tell fellow to target self
				str := fellow.target_str(this)
				; and follow
				str .= fellow.bindings.follow
				Dbg("Following ON:  {} -> {}", fellow.title, this.title)
				SendWin(fellow.title, str)
				fellow._following := this
			} else {
				; off; blip forward
				str := fellow.bindings.forward
				Dbg("Following OFF: {}", fellow.title)
				SendWin(fellow.title, str)
				fellow._following := false
			}
		} else if ( fellow ) {
			Dbg("Can't follow self! ({})", this.title)
		} else {
			Dbg("INTERNAL: _follow_on: fellow is NULL")
		}
	}



	;========================================
	send_following(keystr, delay:=-1, nudge:=0)
	; Send keystr to self and any following windows (after a default delay) 
	; and continue following.
	; If delay is not provided, use the default delay.
	; If nudge is 1, then move forward a bit after keystr, before refollowing
	; (necessary for toggling walk/run on followers).
	; If nudge is 2, then don't refollow (avoids warsteed dismount bug)
	{
		slept := false
		if ( delay < 0 ) {
			delay := this.follow_delay
		}
		SendWin(this.title, keystr)
		for k, win in LotroWin.Windows {
			if ( win._following == this ) {
				; sleep first
				if ( !slept ) {
					if ( delay > 0 ) {
						Sleep(delay)
					}
					slept := true
				}
				; follower:  target me, keystr, re-follow
				str := win.target_str(this)
				str .= keystr
				if ( nudge == 1) {
					str .= win.bindings.forward
				}
				if ( nudge != 2 ){
					; don't follow after a warsteed dismount
					; (triggers a very odd jerky movement bug).
					str .= win.bindings.follow
				}
				SendWin(win.title, str)
			}
		}
	}

	;========================================
	fellow_select(n)
	; Select fellow n as the selected fellow.
	; n = 1 ==> first fellow (after self)
	{
		if ( this._fellows && n > 0 && n <= this._fellows.Length() ){
			this._selected := this._fellows[n]
			Dbg("SELECT: {}", this._selected.title)
		} else {
			this._selected := false
			Dbg("SELECT: <void>")
		}
	}

	;========================================
	fellow_skill(n)
	; Send the selected fellow its skill n.
	{
		fellow := this._selected
		if ( fellow ) {
			SendWin(fellow.title, fellow.skills[n])
		}
	}

	;========================================
	fellow_send(keystr)
	; Send the selected fellow 'keystr'
	{
		fellow := this._selected
		if ( fellow ) {
			SendWin(fellow.title, keystr)
		}
	}

	;========================================
	fellow_move_start()
	; Start fellow movement
	; XXX: lots of issues with Ctrl here
	{
		fellow := this._selected
		if ( fellow ){
			if ( ! fellow._moving ) {
				ActivateWin(fellow.title)
				FocusWin(fellow.title)
				str := "{" . fellow.bindings.forward . " down}"
				; XXX: Somehow Ctrl Down is being sent to the fellow...
				; str .= "{Ctrl up}"
				SendWin(fellow.title, str)
				fellow._moving := true
			} else {
				; send more 
				str := "{" . fellow.bindings.forward . " down}"
				SendWin(fellow.title, str)
			}
		}
	}

	;========================================
	fellow_move_stop()
	; End fellow movement
	{
		fellow := this._selected
		if ( fellow ){
			if ( fellow._moving ){
				str := "{" . fellow.bindings.forward . " up}"
				SendWin(fellow.title, str)
				UnfocusWin(fellow.title)
				ActivateWin(this.title)
				fellow._moving := false
			}
		}
	}

	;========================================
	target_str(fellow)
	; Return a string for this window to target 'fellow'.
	{
		return this._select_str( fellow, this.bindings.target )
	}
	;========================================
	assist_str(fellow)
	; Return a string for this window to assist 'fellow'.
	{
		return this._select_str( fellow, this.bindings.assist )
	}

	;========================================
	_select_str(fellow, keys)
	; Return a string for this window to target/assist 'fellow'.
	; keys is an array[6] of key strings to target/assist fellow 1-6
	{
		n := IndexOf(this.fellows, fellow.title)

		; sanity check
		if ( this._fellows[n] != fellow ){
			Dbg("INTERNAL: _select_str: {}'s _fellows[{}]='{}'"
				. "object doesn't match object fellow='{}'"
				, this.title, n, this._fellows[n].title, fellow.title)
		}
		n += 1			; first key is alway self; skip it
		return keys[n]
	}

	;========================================
	dump()
	; dump this instance's datastructures
	{
		;Dump(this)
		Dbg( "  title : ""{}"":", this.title )
		Dbg( "      {:-15s} : {},{}  {},{}", "w,h  x,y"
			,this.width, this.height, this.x, this.y )
		Dbg( "      {:-15s} : {}", "follow_delay", this.follow_delay)
		Dbg( "      {:-15s} : {} ", "_following"
			, this._following ? this._following.title : "false" )
		Dbg( "      {:-15s} : {} ", "_selected"
			, this._selected ? this._selected.title : "false" )
		Dbg( "      {:-15s} : {} ", "_selected"
			, this._moving ? "true" : "false" )
		Dbg( "      {:-15s} : {} ", "bindings"
			, this.bindings ? Repr(this.bindings) : "false" )
		Dbg( "      {:-15s} : {} ", "skills", Repr(this.skills))
		Dbg( "      {:-15s} : {} ", "fellows", Repr(this.fellows))
		Dbgn("      {:-15s} : ", "_fellows")
		if ( this._fellows ) {
			Dbgn("[")
			first := true
			for k, o in this._fellows {
				if ( first ){
					first := false
				} else {
					Dbgn(", ")
				}
				Dbgn( """{}""", o.title )
			}
			Dbg("]")
		} else {
			Dbg("0")
		}
	}
}
