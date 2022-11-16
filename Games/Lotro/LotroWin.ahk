; LotRO Window object

; A LotRO window represents a character/toon in a fellowship
; with assorted methods to take actions within the fellowship.

;===============================================================================
; Copyright 2020 Chris Roehrig <croehrig@crispart.com>
; 
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
; 
; 1. Redistributions of source code must retain the above copyright notice,
; this list of conditions and the following disclaimer.
; 
; 2. Redistributions in binary form must reproduce the above copyright notice,
; this list of conditions and the following disclaimer in the documentation
; and/or other materials provided with the distribution.
; 
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
; POSSIBILITY OF SUCH DAMAGE.

;===============================================================================
;#Include util.ahk
;#Include io.ahk

LotroInactiveWinTitle := "LotRO INACTIVE"

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
	static Windows := []			; the list of all defined window objects
	static _selectstate	:= false	; Array of fellow select states

	;==========================================================================
	; Instance Properties
	; These should be filled in by passing a corresponding dictionary object
	; to the constructor.
	title	:= ""		; The window title

	; Window position: default to 1280x720
	winpos := { width: 1280, 	height: 720,	x:0,	y:0 }

	fellows	:= false		; array of window titles of fellows (in order)
	skills	:= false		; array of skill key strings for this window[DEL]

	; These 2 are arrays of the same length as bindings.skills:
	skilltarget := false	; array of remote skill target fellow (0-5)
							; 0 == self
							; -1 == none; do not change target
							; -2 == use defaulttarget
	skillassist := false	; array of bool; true == assist instead of target

	defaulttarget := -1		; default fellow target for remote skills (0-5)

	defaultfellow := false	; default fellow for hotkey actions from this win
							; 1 == first fellow

	; dictionary of key bindings (as an example of required bindings)
	bindings := 	{_:0
		,forward		: "e"							; move forward
		,follow			: "+{Tab}" 						; follow target
		; keys to target/assist fellows 1-6  (1 == self)
		,target 		: [  "^{F1}", "^{F2}", "^{F3}"
							,"^{F4}", "^{F5}", "^{F6}" ]
		,assist 		: [  "+{F1}", "+{F2}", "+{F3}"
							,"+{F4}", "+{F5}", "+{F6}" ]
		; keys to fire remote skills for this window 1-N 
		,skills 		: [  "{F1}", "{F2}", "{F3}"
							,"{F4}", "{F5}", "{F6}" ]
		,_:0}


	;========================================
	; Internal instance variables
	; State
	_following		:= false	; the object being followed
								; (distinct from commander when daisy-chained)
	_commander		:= false	; the object who is the commander
	_fellows		:= false	; array of LotroWins corresponding to fellows
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
		LotroWin._selectstate := []
		for k, win in LotroWin.Windows {
			; set up array of fellow object
			if (win.fellows) {
				win._fellows := []
				for k, title in win.fellows {
					f := LotroWin.getwin(title)
					if ( f ) {
						win._fellows.Push(f)
					} else {
						Dbg("WARNING: finalize [{}]: no fellow window "
								. "named '{}' found.", win.title, title )
						win._fellows.Push(false)
					}
				}
			}
			LotroWin._selectstate.Push(false)
		}
	}

	;========================================
	SetSelect(n, val)
	; Class method to set the fellow selectstate(n) to 'val' (true/false)
	{
		if ( LotroWin._selectstate 
					&& n > 0 
					&& n <= LotroWin._selectstate.Length() ){
			if ( val ) {
				if ( ! LotroWin._selectstate[n] ) {	; avoid auto-repeat
					Dbg("SELECTSTATE[{}]  ON", n)
					LotroWin._selectstate[n] := true
				}
			} else {
				Dbg("SELECTSTATE[{}]  OFF", n)
					LotroWin._selectstate[n] := false
			}
		} else {
			Dbg( "SetSelect: n={} is out-of-bounds!", n )
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
		Dbg("WARNING: no such fellow window: [{}]", title )
		return false
	}

	;========================================
	layout_win()
	; Class method to layout all windows in windowed mode.
	{
		global WinBorderX, WinBorderY
		global LotroLayout_w, LotroLayout_wbg
		cmd := "/ui layout load "
		active := LotroWin.Active
		for k, w in LotroWin.Windows {
			title := w.title
			WinGetPos, x, y, width, height, %title%
			Dbg("BEFORE: [{}]: {}x{} @ {},{}", w.title, width, height, x, y )
			x := w.winpos.x
			y := w.winpos.y
			width := w.winpos.width + WinBorderX
			height := w.winpos.height + WinBorderY
			MoveWin( w.title, x, y, width, height )
			WinGetPos, x, y, width, height, %title%
			Dbg("AFTER:  [{}]: {}x{} @ {},{}", w.title, width, height, x, y )
			if ( w.title == active.title ) {
				SendChat("", cmd . LotroLayout_w . "{Enter}")
			} else {
				SendChat(w.title, cmd . LotroLayout_wbg . "{Enter}")
			}
		}
		return
	}

	;========================================
	layout_full()
	; Class method to layout all windows with Active in fullscreen
	{
		global FullScreen
		global LotroLayout_f, LotroLayout_wbg
		cmd := "/ui layout load "
		active := LotroWin.Active
		MoveWin( "A", 0, 0, FullScreen.width, FullScreen.height )
		for k, w in LotroWin.Windows {
			if ( w.title == active.title ) {
				SendChat("", cmd . LotroLayout_f . "{Enter}")
			} else {
				SendChat(w.title, cmd . LotroLayout_wbg . "{Enter}")
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
		Dbgnt( "  {:-15s} : {} ", "_selectstate" , Repr(LotroWin._selectstate))
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
	follow_me(on:=true, delay:=0)
	; Tell the currently selected fellow to follow me (on=true) or stop (false)
	; or if none are selected, tell all to fellows to follow me.
	; Delay is in milliseconds.
	{
		selfellow := this._get_selfellow()
		if ( selfellow ) {
			if ( on ){
				selfellow._follow(this)
				selfellow._commander := this
			} else {
				selfellow._follow(false)
				selfellow._commander := false
			}
		} else {
			; no selected fellow: everyone follows
			if ( on ){
				; on - Quickly change the state of all followers
				; (in case another async follow occurs before we're finished)
				target := this
				for k, win in this._fellows {
					Dbg("[{}]:  [{}] quick-starts following."
						, this.title, win.title)
					win._following := target
					win._commander := this
					target := win		; daisy-chain followers
				}
				; then send the following keys after requisite delays
				target := this
				for k, win in this._fellows {
					if ( delay > 0 ) {
						Dbg("[{}]: Sleeping {} ms for [{}]"
						, this.title, delay, win.title )
						Sleep(delay)
					}
					win._follow(target)
					target := win		; daisy-chain followers
				}
			} else {
				; off -  stop following immediately
				for k, win in this._fellows {
					win._follow(false)
					win._commander := false
				}
			}
		}
	}

	;========================================
	_follow(leader:=false)
	; Follow leader (or stop following if it is false).
	; NB: this does not change _commander; use follow_me*() for bindings
	{
		if ( leader ) {
			if ( leader == this ){
				Dbg("[{}]: INTERNAL: Can't follow self!", this.title)
			} else {
				; Target leader
				str := this.target_str(leader)
				; and follow
				str .= this.bindings.follow
				Dbg("[{}]: Following [{}]", this.title, leader.title)
				SendWin(this.title, str)
				this._following := leader
			}
		} else {
			; turn following off; blip forward
			str := this.bindings.forward
			Dbg("[{}]: Following OFF", this.title )
			SendWin(this.title, str)
			this._following := false
		}
	}



	;========================================
	follower_hotkey(hotkeystr, delay:=0, nudge:=0)
	; If a fellow is selected, send hotkeystr to it; otherwise:
	; send hotkeystr to self and any following windows (after a possible delay) 
	; and continue following.
	; Delay is in milliseconds.
	; If nudge is 1, then move forward a bit after hotkeystr, before refollowing
	; (necessary for toggling walk/run on followers).
	; If nudge is 2, then don't refollow (avoids warsteed dismount bug)
	; NB: hotkeystr is a hotkey string a'la A_ThisHotkey and is expanded
	{
		keystr := ExpandHotKey(hotkeystr)

		selfellow := this._get_selfellow()
		if ( selfellow ) {
			SendWin(selfellow.title, keystr)
			return
		}

		; no selfellow -- send to me and followers
		SendWin(this.title, keystr)		; send to me
		for k, win in LotroWin.Windows {
			if ( win._commander == this ) {
				; sleep first
				if ( delay > 0 ) {
					Dbg("[{}]: Sleeping {} ms", this.title, delay )
					Sleep(delay)
				}
				; target me and send keystr
				str := win.target_str(this)
				str .= keystr
				if ( nudge == 1) {
					str .= win.bindings.forward
				}
				SendWin(win.title, str)

				; re-follow
				if ( win._following ) {
					if ( nudge != 2 ){
						; don't follow after a warsteed dismount
						; (triggers a very odd jerky movement bug).
						str := win.target_str(win._following)
						str .= win.bindings.follow
						SendWin(win.title, str)
					}
				}
			}
		}
	}

	;========================================
	_get_selfellow()
	; Return the currently selected fellow based on the KeyState
	; value in _selectstate.
	; i.e. if that key is physically held down, then that fellow is selected.
	; The first match is returned, or 'false' if none is selected.
	{
		selfellow := false
		; NB: GetKeyState() is not reliable (doesn't release), so we
		; need to manage the state with explicit up/down hotkeys.
;		for i, key in this.bindings.fellowselect {
;			if (GetKeyState(key, "p")) {
		for i, val in LotroWin._selectstate {
			if ( val ) {
				if ( i > 0 && i <= this._fellows.Length() ){
					selfellow := this._fellows[i]
					Dbg("[{}]: SELFELLOW: [{}]", this.title, selfellow.title)
				}
			}
		}

		return selfellow
	}

	;========================================
	_get_defaultfellow()
	; Return the default fellow defined for this window.
	{
		n := this.defaultfellow
		if ( ! n ) {
			return false
		}
		if ( this._fellows && n > 0 && n <= this._fellows.Length() ){
			selfellow := this._fellows[n]
			Dbg("[{}]: SELFELLOW[default]: [{}]", this.title, selfellow.title)
		} else {
			selfellow := false
			Dbg("[{}]: SELFELLOW[default]: <void>", this.title )
		}
		return selfellow
	}

	;========================================
	set_defaultfellow(n)
	; Set the default fellow to n
	{
		if ( this._fellows && n > 0 && n <= this._fellows.Length() ){
			selfellow := this._fellows[n]
			this.defaultfellow := n
			Dbg("[{}]: SET defaultfellow={} [{}]"
				, this.title, n, selfellow.title )
		} else {
			Dbg("[{}]: SET defaultfellow: INVALID: {}", this.title, n )
		}
	}

	;========================================
	set_defaulttarget(n)
	; Set the default target of the selected (or default) fellow to n.
	{
		selfellow := this._get_selfellow()
		if ( ! selfellow ) {
			selfellow := this._get_defaultfellow()
			if ( ! selfellow ) {
				return
			}
		}

		selfellow.defaulttarget := n
		if ( n > 0 && n <= selfellow.fellows.Length() ) {
			Dbg("[{}]: SET defaulttarget={} [{}]"
				, selfellow.title, n, selfellow.fellows[n] )
		} else if ( n == 0 ){
			Dbg("[{}]: SET defaulttarget={} <self>", selfellow.title, n)
		} else {
			Dbg("[{}]: SET defaulttarget={}", selfellow.title, n)
		}

		; Send selfellow a retarget:
		if ( n+1 <= selfellow.bindings.target.Length() ){
			SendWin(selfellow.title, selfellow.bindings.target[n+1])
		}
	}


	;========================================
	fellow_skill(n)
	; Send the selected fellow its skill n (includes target/assist keystroke)
	{
		selfellow := this._get_selfellow()
		if ( ! selfellow ) {
			selfellow := this._get_defaultfellow()
			if ( ! selfellow ) {
				return
			}
		}

		; range checks:
		if ( n < 0 || n > selfellow.bindings.skills.Length() ) {
			Dbg("ERROR: [{}]: has no bindings.skills[{}]", selfellow.title, n)
			return
		}
		if ( n < 0 || n > selfellow.skilltarget.Length() ) {
			Dbg("ERROR: [{}]: has no skilltarget[{}]", selfellow.title, n)
			return
		}
		if ( n < 0 || n > selfellow.skillassist.Length() ) {
			Dbg("ERROR: [{}]: has no skillassist[{}]", selfellow.title, n)
			return
		}

		; construct the string
		targ := selfellow.skilltarget[n]
		dbgmsg := ""
		if ( targ == -2 ){
			; default target
			targ := selfellow.defaulttarget
			dbgmsg .= "[default]"
		}
		if ( targ >= 0 ) {
			if ( selfellow.skillassist[n] ){
				; assist fellow[targ]
				str := selfellow.bindings.assist[targ+1]		; 1-offset
				dbgmsg .= "Assist:["
			} else {
				; target fellow[targ]
				str := selfellow.bindings.target[targ+1]		; 1-offset
				dbgmsg .= "Target:["
			}
			if ( targ <= selfellow.fellows.Length() ) {
				dbgmsg .= selfellow.fellows[targ]
			} else {
				dbgmsg .= targ		; another party member
			}
			dbgmsg .= "]"
		} else {
			str := ""		; no target
			dbgmsg .= "<No target>"
		}

		; add the actual skill hotkey
		str .= selfellow.bindings.skills[n]

		Dbg("SKILL: [{}]: --> [{}]: skills[{}] with " . dbgmsg
				,this.title, selfellow.title, n)
		SendWin(selfellow.title, str)
	}

	;========================================
	fellow_send(keystr)
	; Send the selected fellow 'keystr' (a fully-expanded key string).
	{
		selfellow := this._get_selfellow()
		if ( ! selfellow ) {
			selfellow := this._get_defaultfellow()
			if ( ! selfellow ) {
				return
			}
		}
		SendWin(selfellow.title, keystr)
	}

	;========================================
	fellow_move_start()
	; Start fellow movement
	; XXX: lots of issues with Ctrl here
	{
		selfellow := this._get_selfellow()
		if ( ! selfellow ) {
			selfellow := this._get_defaultfellow()
			if ( ! selfellow ) {
				return
			}
		}
		if ( ! selfellow._moving ) {
			ActivateWin(selfellow.title)
			FocusWin(selfellow.title)
			str := "{" . selfellow.bindings.forward . " down}"
			; XXX: Somehow Ctrl Down is being sent to the fellow...
			; str .= "{Ctrl up}"
			SendWin(selfellow.title, str)
			selfellow._moving := true
		} else {
			; send more 
			str := "{" . selfellow.bindings.forward . " down}"
			SendWin(selfellow.title, str)
		}
	}

	;========================================
	fellow_move_stop()
	; End fellow movement
	{
		selfellow := this._get_selfellow()
		if ( ! selfellow ) {
			selfellow := this._get_defaultfellow()
			if ( ! selfellow ) {
				return
			}
		}
		if ( selfellow._moving ){
			str := "{" . selfellow.bindings.forward . " up}"
			SendWin(selfellow.title, str)
			UnfocusWin(selfellow.title)
			ActivateWin(this.title)
			selfellow._moving := false
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
			Dbg("[{}]: INTERNAL: _select_str: _fellows[{}]='{}'"
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
		Dbg( "  title : [{}]:", this.title )
		wpos := this.winpos
		Dbgnt( "      {:-15s} : {},{}  {},{}", "w,h  x,y"
			,wpos.width, wpos.height, wpos.x, wpos.y )
		Dbgnt( "      {:-15s} : {} ", "_following"
			, this._following ? this._following.title : "false" )
		Dbgnt( "      {:-15s} : {} ", "_commander"
			, this._commander ? this._commander.title : "false" )
		Dbgnt( "      {:-15s} : {} ", "_moving"
			, this._moving ? "true" : "false" )
		Dbgnt( "      {:-15s} : {} ", "bindings"
			, this.bindings ? Repr(this.bindings) : "false" )
		Dbgnt( "      {:-15s} : {} ", "fellows", Repr(this.fellows))
		Dbgn(  "      {:-15s} : ", "_fellows")
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
			Dbgnt("]")
		Dbgnt( "      {:-15s} : {} ", "defaultfellow", this.defaultfellow )
		Dbgnt( "      {:-15s} : {} ", "skills", Repr(this.skills))
		Dbgnt( "      {:-15s} : {} ", "skilltarget", Repr(this.skilltarget))
		Dbgnt( "      {:-15s} : {} ", "skillassist", Repr(this.skillassist))
		Dbgnt( "      {:-15s} : {} ", "defaulttarget", this.defaulttarget)
		} else {
			Dbgnt("0")
		}
	}

}
