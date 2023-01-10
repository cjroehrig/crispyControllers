; LotroWin	- object describing a LotRO window
; LotroRole - object describing a role that a window can take.

; A LotRO window represents a character/toon in a fellowship
; with assorted methods to take actions within the fellowship.

; REQUIRES SetTitleMatchMode 1

;===============================================================================
; Copyright 2022 Chris Roehrig <croehrig@crispart.com>
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
;#Include numerical.ahk

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

;===============================================================================
class LotroRole {
	; This class holds 
	;==========================================================================
	; Class properties
	static RoleList := []			; the list of all defined LotroRoles

	;==========================================================================
	; Instance Properties
	; These should be filled in by passing a corresponding dictionary object
	; to the constructor.
	name := false			; This is used to create a window's title
	idx := -1				; the index in the RoleList

	; Window position: default to 1280x720
	winpos := { width: 1280, 	height: 720,	x:0,	y:0 }

	; These 2 are arrays of the same length as bindings.skills:
	skilltarget := false	; array of remote skill targets
;			-2		use the remote fellow's currtarget
;			-1		No target: don't change target/assist
;			0		self
;			1-N		target/assist that fellowship member
;			role	target/assist the first fellow with matching role (string)
;					this can also use a suffix 2,3,4,... to match other instances
	skillassist := false	; array of bool for each remote skill.  
;			0		target the skilltarget before firing the skill
;			1		assist the skilltarget before firing the skill
	defaulttarget := -1		; initial currtarget of each instance of this role
;				  	(-1, 0, 1-N, role  - as defined for skilltarget)
	defaultfellow := false	; default fellow for hotkey actions from this win
;					(1-N, or role)



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

	;==========================================================================
	; Instance Methods

	;========================================
	__New(name, settings)
	; CONSTRUCTOR: Initialize this object with a dictionary of settings,
	; and add it to the class window list.
	{
		;Dbg( "LotroRole::__New()" )
		for key, value in settings {
			;Dbg( "  [{}] <-- {}", key, value )
			this[key] := value
		}
		this.name := name
		this.idx := LotroRole.RoleList.Length() + 1
		LotroRole.RoleList.Push(this)
		return this
	}

	;========================================
	dump()
	; dump this instance's datastructures
	{
		Dbg( "LotroRole[{}] name : {}:", this.idx, this.name )
		wpos := this.winpos
		Dbgnt( "      {:-15s} : {},{}  {},{}", "w,h  x,y"
			,wpos.width, wpos.height, wpos.x, wpos.y )

		Dbgnt( "      {:-15s} : {} ", "skilltarget", Repr(this.skilltarget))
		Dbgnt( "      {:-15s} : {} ", "skillassist", Repr(this.skillassist))
		Dbgnt( "      {:-15s} : {} ", "defaulttarget", this.defaulttarget)
		Dbgnt( "      {:-15s} : {} ", "defaultfellow", this.defaultfellow )
		Dbgnt( "      {:-15s} : {} ", "bindings"
			, this.bindings ? Repr(this.bindings) : "false" )
	}

}



;===============================================================================
class LotroWin {
	; 

	;==========================================================================
	; Class properties
	static WindowList := []			; the list of all current LotroWin objects
	static TitlePrefix := "LotRO "	; Window title prefix (followed by .name)
	;static ExpandedTitle := false	; add additional info to title bar
	static ExpandedTitle := true	; add additional info to title bar
	; Array of 6 fellow select button states:
	static _selectstate	:= [false, false, false, false, false, false]

	;==========================================================================
	; Instance Properties
	name			:= false		; The window's name
	title			:= false		; The window title
		; NB: 'title' is used to identify/match windows by AutoHotKey,
		; prefix doesn't appear to work reliably so this is the full title
		; and since this is just a prefix, this class REQUIRES:
		; 		SetTitleMatchMode 1
	fulltitle		:= false		; The window's full title (with extra info)
	role			:= false		; The window's LotroRole object
	fellows			:= []			; array of LotroWin fellows (in party order)


	;========================================
	; Internal instance variables
	; State
	currtarget		:= false	; the currenttarget for remote skills
	defaultfellow	:= false	; the default fellow for hotkeys
	following		:= false	; the object being followed
								; (distinct from commander when daisy-chained)
	commander		:= false	; the object who is the commander
	moving			:= false	; true if this window is "fellow_moving"
	_oldtitle		:= false	; prev title used to identify the window

	_permtest		:= false	; disable
	;_permtest		:= [ "A", "B", "C", "D", "E" ]	; RotateParty test


	;==========================================================================
	; Class Methods

	;========================================
	; Active is a read-only class property that returns the LotroWin object
	; with the current active window.
	Active[] {
		get {
			return LotroWin.GetWin(GetActiveTitle())
		}
		set {
		}
	}

	;========================================
	SetSelect(n, val)
	; Class method to set the select button(n) state to 'val' (true/false)
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
			Dbg( "ERROR: SetSelect: n={} is out-of-bounds!", n )
		}
	}

	;========================================
	GetWin(title)
	; Class method to return the window with given title (prefix)
	{
		for k, win in LotroWin.WindowList {
			if ( IsPrefix(win.title, title) ){
				return win
			}
		}
		;Dbg("WARNING: no such fellow window: [{}]", title )
		return false
	}

	;========================================
	Reset()
	; Class method to remove all defined LotroWins.
	; Useful when starting a new Lotro session when AutoHotKey
	; is still running from last time.
	{
		while ( LotroWin.WindowList.Length() > 0 ){
			LotroWin.WindowList[1].destroy()
		}
		for k, v in LotroWin._selectstate {
			LotroWin._selectstate[k] := false
		}
		SetActiveTitle("The Lord of the Rings Online")
	}

	;========================================
	ResetRoles()
	; Class method to reset all windows' role defaults.
	{
		for k, win in LotroWin.WindowList {
			win.set_role(win.role)
		}
		for k, win in LotroWin.WindowList {
			win.update_title()
		}
	}


	;========================================
	RotateName()
	; Class method to rotate the name/title of the Active window
	; through all the defined LotroRoles.
	; Once through the list, the title will changed to INACTIVE
	; and be dropped from the WindowList.
	{
		win := LotroWin.Active
		if ( !win ){
			; new LotroWin
			win := new LotroWin(LotroRole.RoleList[1])
			win.title := GetActiveTitle()
		} else {
			idx := win.role.idx + 1
			if ( idx > LotroRole.RoleList.Length() ){
				; INACTIVE
				win.destroy()
				title := LotroWin.TitlePrefix . "INACTIVE "
				SetWindowTitle(win.title, title)
			} else {
				role := LotroRole.RoleList[idx]
				win.set_role(role)
			}
		}
		LotroWin.UpdateNames()
	}

	;========================================
	RotateParty(n:=1)
	; Class method to rotate the party order of the Active window.
	; This cycles through all permutations in steps of 'n' in
	; lexicographic order (the most intuitive).
	; For a full party, there are 5!=120 permutations, so n=10 can be used
	; to "fast-forward".
	{
		win := LotroWin.Active
		if ( !win ){
			Dbg("RotateParty: active window is not a LotroWin")
			return
		}
		i := 1
		while ( i <= n ){
			if (win._permtest){
				NextPermutation(win._permtest)
			} else if (win.fellows ) {
				NextPermutation(win.fellows, Func("CmpObject"))
			}
			i += 1
		}
		for k, win in LotroWin.WindowList {
			win.update_title()
		}
	}

	;========================================
	UpdateNames()
	; Update all window names/titles.
	{
		; create new names for all windows
		for k, win in LotroWin.WindowList {
			name := win.role.name
			suffix := ""
			loop {
				; check window name doesn't already exist
				duplicate := false
				i := 1
				while ( i < k ) {
					w := LotroWin.WindowList[i]
					if ( w.name == name . suffix ) { 
						duplicate := true
						break
					}
					i += 1
				}
				if ( ! duplicate ) {
					break
				}
				; duplicate -- append a digit
				if ( suffix == "" ) {
					suffix := 2
				} else {
					suffix += 1
				}
			}
			win.name := name . suffix
		}

		; update the window titles
		for k, win in LotroWin.WindowList {
			win.update_title()
		}
	}

	;========================================
	LayoutWindowed()
	; Class method to layout all windows in windowed mode.
	{
		global WinBorderX, WinBorderY
		global LotroLayout_w, LotroLayout_wbg
		cmd := "/ui layout load "
		active := LotroWin.Active
		for k, w in LotroWin.WindowList {
			title := w.title
			role := w.role
			WinGetPos, x, y, width, height, %title%
			Dbg("Layout BEFORE: [{}]: {}x{} @ {},{}"
				, w.name, width, height, x, y )
			x := role.winpos.x
			y := role.winpos.y
			width := role.winpos.width + WinBorderX
			height := role.winpos.height + WinBorderY
			MoveWin( w.title, x, y, width, height )
			WinGetPos, x, y, width, height, %title%
			Dbg("Layout AFTER:  [{}]: {}x{} @ {},{}"
				, w.name, width, height, x, y )
			if ( w.title == active.title ) {
				SendChat("", cmd . LotroLayout_w . "{Enter}")
			} else {
				SendChat(w.title, cmd . LotroLayout_wbg . "{Enter}")
			}
		}
		return
	}

	;========================================
	LayoutFullscreen()
	; Class method to layout all windows with Active in fullscreen
	; XXX: this should really be called LoadAllUILayouts()
	{
		global FullScreen
		global LotroLayout_f, LotroLayout_wbg
		cmd := "/ui layout load "
		active := LotroWin.Active
		;MoveWin( "A", 0, 0, FullScreen.width, FullScreen.height )
		for k, w in LotroWin.WindowList {
			if ( w.title == active.title ) {
				SendChat("", cmd . LotroLayout_f . "{Enter}")
			} else {
				SendChat(w.title, cmd . LotroLayout_wbg . "{Enter}")
			}
		}
		return
	}

	;========================================
	FollowerHotKey(hotkeystr, delay:=0, nudge:=0)
	; If the active window is a LotroWin, then send this
	; to Active.follower_hotkey; otherwise send it to the active window.
	{
		win := LotroWin.Active
		if (win) {
			win.follower_hotkey(hotkeystr, delay, nudge)
		} else {
			; not a LotroWin; just an ordinary LotRO instance
			keystr := ExpandHotKey(hotkeystr)
			Send, %keystr%					; send to active window
		}
	}

	;========================================
	DumpAll()
	; dump our class
	{
		Dbg("=================================================")
		Dbg("DUMP: LotroRole.RoleList (Length={}):"
				, LotroRole.RoleList.Length())
		for k, role in LotroRole.RoleList {
			role.dump()
		}
		Dbg("DUMP: LotroWin.WindowList (Length={}):"
				, LotroWin.WindowList.Length())
		Dbgnt( "  {:-15s} : {} ", "_selectstate" , Repr(LotroWin._selectstate))
		for k, win in LotroWin.WindowList {
			win.dump()
		}
	}

	;==========================================================================
	; Instance Methods

	;========================================
	__New(role)
	; CONSTRUCTOR: Create a new object with the given LotroRole
	; and add it to the class window list.
	{
		Dbg( "LotroWin::__New({})", role.name )
		this.idx := LotroWin.WindowList.Length() + 1
		LotroWin.WindowList.Push(this)
		this.set_role(role)
		Dbg( "   CREATED [{}]<{}>", this.idx, role.name )

		; add us to everyone else's fellows (and them to ours)
		for k, win in LotroWin.WindowList {
			if ( win != this ){
				this.fellows.Push(win)
				win.fellows.Push(this)
			}
		}

		return this
	}
	;========================================
	set_role(role)
	; Set this window's role to 'role' and initialize it
	{
		this.role := role
		this.defaultfellow := role.defaultfellow
		this.currtarget := role.defaulttarget
	}

	;========================================
	destroy()
	; Destroy this window and remove it from the WindowList
	{
		Dbg( "LotroWin::destroy([{}]{})", this.idx, this.name )
		LotroWin.WindowList.RemoveAt(this.idx)

		; renumber window indexes and remove from all fellow lists
		for k, win in LotroWin.WindowList {
			win.idx := k
			for i, fellow in win.fellows {
				if ( fellow == this ){
					win.fellows.RemoveAt(i)
				}
			}
		}
	}

	;========================================
	update_title()
	; Update the window title to reflect a new party, or other new info.
	; this.fulltitle is the actual full window title string.
	; this.title is the title prefix used in all I/O calls to match the window
	; and needs to uniquely identify the window.
	{
		; Use a space as a positive terminator:
		title := LotroWin.TitlePrefix . this.name . " "

		fulltitle := title
		if ( this._permtest ){
			; for permutation testing...
			for j, fellow in this._permtest {
				fulltitle .= " - " . fellow
			}
		} else {
			for j, fellow in this.fellows {
				fulltitle .= " - " . fellow.name
			}
		}

		if ( LotroWin.ExpandedTitle ){
			if ( this.fellows.Length() > 0 ){
				; add info to titlebar
				fulltitle .= "                                 "
				fulltitle .= "     currtarget:" . this.get_currtarget_str()
				if ( this.fellows.Length() > 1 ) {
					fulltitle .= "                                 "
					fellow := this.get_defaultfellow()
					fulltitle .= "defaultfellow:"
					fulltitle .= fellow ? fellow.name :"NONE"
				}
			}
		}

		; update the title
		if ( fulltitle != this.fulltitle ){
			SetWindowTitle(this.title, fulltitle)
			this.title := title
			this.fulltitle := fulltitle
		}
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
				selfellow.following := this
				selfellow.commander := this
				selfellow._send_follow(this)
			} else {
				selfellow.following := false
				selfellow.commander := false
				selfellow._send_follow(false)
			}
		} else {
			; no selected fellow: everyone follows
			if ( on ){
				; on - Quickly change the state of all followers
				; (in case another async follow occurs before we're finished)
				target := this
				for k, win in this.fellows {
					Dbg("[{}]:  [{}] quick-starts following."
						, this.name, win.name)
					win.following := target
					win.commander := this
					target := win		; daisy-chain followers
				}
				; then send the following keys after requisite delays
				for k, win in this.fellows {
					if ( delay > 0 ) {
						Dbg("[{}]: Sleeping {} ms for [{}]"
						, this.name, delay, win.name )
						Sleep(delay)
					}
					; NB: async: state could have changed in the meantime...
					if ( win.following ) {
						win._send_follow(win.following)
					}
				}
			} else {
				; off -  stop following immediately
				for k, win in this.fellows {
					win._send_follow(false)
					win.following := false
					win.commander := false
				}
			}
		}
	}

	;========================================
	_send_follow(leader:=false)
	; Send bindings to follow leader (or stop following if it is false).
	{
		if ( leader ) {
			if ( leader == this ){
				Dbg("[{}]: INTERNAL: Can't follow self!", this.name)
			} else {
				; Target leader
				str := this.target_str(leader)
				; and follow
				str .= this.role.bindings.follow
				Dbg("[{}]: Following [{}]", this.name, leader.name)
				SendWin(this.title, str)
			}
		} else {
			; turn following off; blip forward
			str := this.role.bindings.forward
			Dbg("[{}]: Following OFF", this.name )
			SendWin(this.title, str)
			this.following := false
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
		for k, win in LotroWin.WindowList {
			if ( win.commander == this ) {
				; sleep first
				if ( delay > 0 ) {
					Dbg("[{}]: Sleeping {} ms", this.name, delay )
					Sleep(delay)
				}
				; target me and send keystr
				str := win.target_str(this)
				str .= keystr
				if ( nudge == 1) {
					str .= win.role.bindings.forward
				}
				SendWin(win.title, str)

				; re-follow
				if ( win.following ) {
					if ( nudge != 2 ){
						; don't follow after a warsteed dismount
						; (triggers a very odd jerky movement bug).
						str := win.target_str(win.following)
						str .= win.role.bindings.follow
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
;		for i, key in this.role.bindings.fellowselect {
;			if (GetKeyState(key, "p")) {
		for i, val in LotroWin._selectstate {
			if ( val ) {
				if ( i > 0 && i <= this.fellows.Length() ){
					selfellow := this.fellows[i]
					Dbg("[{}]: SELFELLOW: [{}]", this.name, selfellow.name)
				}
			}
		}

		return selfellow
	}

	;========================================
	get_defaultfellow()
	; Return the default fellow defined for this window.
	; NB: this has the side-effect of setting it to the actual fellow object
	{
;		if ( IsObject(this.defaultfellow) ){
;			; fast-path
;			Dbg("[{}]: SELFELLOW[default]: [{}]"
;				, this.name, this.defaultfellow.name )
;			return this.defaultfellow
;		}

		if ( IsInteger(this.defaultfellow) ){
			n := this.defaultfellow
			if ( this.fellows && n > 0 && n <= this.fellows.Length() ){
				selfellow := this.fellows[n]
			} else {
				selfellow := false
			}
		} else {
			selfellow := false
			for k, fellow in this.fellows {
				if ( IsPrefix(this.defaultfellow, fellow.name) ){
					selfellow := fellow
					break
				}
			}
		}
		if ( selfellow ){
			Dbg("[{}]: SELFELLOW[default]: [{}]", this.name, selfellow.name)
;			this.defaultfellow := selfellow		; set for fast-path
		} else {
			if ( this.fellows.Length() > 0 ){
				; no match - default to the first fellow
				selfellow := this.fellows[1]
				Dbg("[{}]: SELFELLOW[default]: [{}] <first>"
					, this.name, selfellow.name )
			} else {
				Dbg("[{}]: SELFELLOW[default]: [{}] <void>"
					, this.name, this.defaultfellow )
			}
		}

		return selfellow
	}

	;========================================
	set_defaultfellow(n)
	; Set the default fellow to n
	{
		this.defaultfellow := n
		if ( this.fellows && n > 0 && n <= this.fellows.Length() ){
			selfellow := this.fellows[n]
			Dbg("[{}]: SET defaultfellow={} [{}]"
				, this.name, n, selfellow.name )
		} else {
			Dbg("[{}]: SET defaultfellow: INVALID: {}", this.name, n )
		}
		this.update_title()
	}

	;========================================
	set_remotetarget(n)
	; Set the currtarget of the selected (or default) remote fellow to n.
	{
		selfellow := this._get_selfellow()
		if ( ! selfellow ) {
			selfellow := this.get_defaultfellow()
			if ( ! selfellow ) {
				return
			}
		}
		selfellow.set_currtarget(n)
	}

	;========================================
	set_currtarget(n)
	; Set our currtarget to n (1..N)
	{
		if ( n > 0 && n <= this.fellows.Length() ) {
			Dbg("[{}]: SET currtarget={} [{}]"
				, this.name, n, this.fellows[n].name )
		} else if ( n == 0 ){
			Dbg("[{}]: SET currtarget={} <self>", this.name, n)
		} else {
			Dbg("[{}]: SET currtarget={}", this.name, n)
		}
		this.currtarget := n

		; Send a retarget (NB: n=0 == self):
		if ( n+1 <= this.role.bindings.target.Length() ){
			SendWin(this.title, this.role.bindings.target[n+1])
		}
		this.update_title()
	}

	;========================================
	get_currtarget()
	; Return this window's current target as an integer 0..N
	{
		if ( IsInteger(this.currtarget) ){
			return this.currtarget
		} else {
			; it's a string; find a match...
			for k, fellow in this.fellows {
				if ( IsPrefix(this.currtarget, fellow.name) ){
					return k
				}
			}
		}
		Dbg("[{}]: get_currtarget: no match '{}' found; using -1 (no target)"
				, this.name, this.currtarget )
		return -1
	}

	;========================================
	get_currtarget_str()
	; Return this window's currtarget as a string
	{
		n := this.get_currtarget()
		if ( n < 0 ) {
			str := "NONE"
		} else if ( n == 0 ) {
			str := "self"
		} else if ( n > 0 and n <= this.fellows.Length() ){
			str := Format("{} [{}]", n, this.fellows[n].name)
		} else {
			str := Format("{}", n)
		}
		return str
	}

	;========================================
	fellow_skill(n)
	; Send the selected fellow its skill n (includes target/assist keystroke)
	{
		selfellow := this._get_selfellow()
		if ( ! selfellow ) {
			selfellow := this.get_defaultfellow()
			if ( ! selfellow ) {
				return
			}
		}
		role := selfellow.role

		; range checks:
		if ( n < 0 || n > role.bindings.skills.Length() ) {
			Dbg("ERROR: Role [{}]: has no bindings.skills[{}]", role.name, n)
			return
		}
		if ( n < 0 || n > role.skilltarget.Length() ) {
			Dbg("ERROR: Role [{}]: has no skilltarget[{}]", role.name, n)
			return
		}
		if ( n < 0 || n > role.skillassist.Length() ) {
			Dbg("ERROR: [{}]: has no skillassist[{}]", role.name, n)
			return
		}

		; construct the string
		targ := role.skilltarget[n]
		dbgmsg := ""
		if ( targ == -2 ){
			; use current target
			targ := selfellow.get_currtarget()
			dbgmsg .= "[default]"
		}
		if ( targ >= 0 ) {
			if ( role.skillassist[n] ){
				; assist fellow[targ]
				str := role.bindings.assist[targ+1]	; 1-offset
				dbgmsg .= "Assist:["
			} else {
				; target fellow[targ]
				str := role.bindings.target[targ+1]	; 1-offset
				dbgmsg .= "Target:["
			}
			if ( targ <= selfellow.fellows.Length() ) {
				dbgmsg .= selfellow.fellows[targ].name
			} else {
				dbgmsg .= targ		; another party member
			}
			dbgmsg .= "]"
		} else {
			str := ""		; no target
			dbgmsg .= "<No target>"
		}

		; add the actual skill hotkey
		str .= role.bindings.skills[n]

		Dbg("SKILL: [{}]: --> [{}]: skills[{}] with " . dbgmsg
				,this.name, selfellow.name, n)
		SendWin(selfellow.title, str)
	}

	;========================================
	fellow_send(keystr)
	; Send the selected fellow 'keystr' (a fully-expanded key string).
	{
		selfellow := this._get_selfellow()
		if ( ! selfellow ) {
			selfellow := this.get_defaultfellow()
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
			selfellow := this.get_defaultfellow()
			if ( ! selfellow ) {
				return
			}
		}
		if ( ! selfellow.moving ) {
			ActivateWin(selfellow.title)
			FocusWin(selfellow.title)
			str := "{" . selfellow.role.bindings.forward . " down}"
			; XXX: Somehow Ctrl Down is being sent to the fellow...
			; str .= "{Ctrl up}"
			;SendWin(selfellow.title, str)		; XXX: this does UnfocusWin
			title := selfellow.title
			ControlSend, , %str%, %title%
			selfellow.moving := true
		} else {
			; send more 
			str := "{" . selfellow.role.bindings.forward . " down}"
			;SendWin(selfellow.title, str)		; XXX: this does UnfocusWin
			title := selfellow.title
			ControlSend, , %str%, %title%
		}
	}

	;========================================
	fellow_move_stop()
	; End fellow movement
	{
		selfellow := this._get_selfellow()
		if ( ! selfellow ) {
			selfellow := this.get_defaultfellow()
			if ( ! selfellow ) {
				return
			}
		}
		if ( selfellow.moving ){
			str := "{" . selfellow.role.bindings.forward . " up}"
			SendWin(selfellow.title, str)
			;UnfocusWin(selfellow.title)
			ActivateWin(this.title)
			selfellow.moving := false
		}
	}

	;========================================
	target_str(fellow)
	; Return a string for this window to target 'fellow'.
	{
		return this._select_str( fellow, this.role.bindings.target )
	}
	;========================================
	assist_str(fellow)
	; Return a string for this window to assist 'fellow'.
	{
		return this._select_str( fellow, this.role.bindings.assist )
	}

	;========================================
	_select_str(fellow, keys)
	; Return a string for this window to target/assist 'fellow'.
	; keys is an array[6] of key strings to target/assist fellow 1-6
	{
		n := IndexOf(this.fellows, fellow)

		; sanity check
		if ( this.fellows[n] != fellow ){
			Dbg("[{}]: INTERNAL: _select_str: fellows[{}]='{}'"
				. "object doesn't match object fellow='{}'"
				, this.name, n, this.fellows[n].name, fellow.name)
		}
		n += 1			; first key is alway self; skip it
		return keys[n]
	}

	;========================================
	dump()
	; dump this instance's datastructures
	{
		Dbg( "LotroWin[{}] name : {}:", this.idx, this.name )
		Dbgnt( "      {:-15s} : [{}]{} ", "role", this.role.idx, this.role.name)
		Dbgnt( "      {:-15s} : {} ", "title", this.title )
		Dbgnt( "      {:-15s} : {} ", "fulltitle", this.fulltitle )
		Dbgnt( "      {:-15s} : {} ", "following"
			, this.following ? this.following.title : "false" )
		Dbgnt( "      {:-15s} : {} ", "commander"
			, this.commander ? this.commander.title : "false" )
		Dbgnt( "      {:-15s} : {} ", "moving"
			, this.moving ? "true" : "false" )
		Dbgnt( "      {:-15s} : {} ", "defaultfellow", this.defaultfellow )
		Dbgnt( "      {:-15s} : {} ", "currtarget", this.currtarget)
		Dbgnt(  "      {:-15s} : {}", "fellows", StrObjNames(this.fellows))
		Dbgnt(  "      {:-15s} : {}", "_permtest", Repr(this._permtest))
	}

}
