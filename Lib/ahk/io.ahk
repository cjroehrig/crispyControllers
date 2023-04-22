; I/O Functions
; This is the only file that should actually result in Windows calls

;===============================================================================
SendDelay := 0
FocusPreDelay := 0
FocusPostDelay := 0

;==============================================================================
; Window functions

;=======================================
GetActiveTitle()
; Return the title of the active window.
{
	WinGetActiveTitle, wintitle
	return wintitle
}

;=======================================
SetActiveTitle(newtitle)
; Set the title of the Active window to 'newtitle'
{
	Dbg("SetActiveTitle({})", newtitle)
	WinSetTitle, A,, %newtitle%
}

;=======================================
SetWindowTitle(title, newtitle)
; Set the title of the window called 'title' to 'newtitle'
{
	Dbg("WinSetTitle({},{})", title, newtitle)
	WinSetTitle, %title%,, %newtitle%
}

;=======================================
MoveWin(title, x, y, width:=0, height:=0)
{
	if ( width && height ){
		WinMove, % title,, x, y, width, height
	} else if ( width ) {
		WinMove, % title,, x, y, width,
	} else if ( height ){
		WinMove, % title,, x, y, , height
	} else {
		WinMove, % title,, x, y
	}
}



;=======================================
RotateWinTitle(windows, init_strs)
; Rotate the Active window title.
; windows:  array of window objects to rotate (obj.title is the title).
; init_strs: Array of regexes.
; If the title matches any of the windows[].title, it sets the title to the
; that of the next window.
; Otherwise, if the title matches any of the regexes in init_strs, the
; title is set to windows[1].title;
; Otherwise does nothing.
{
	WinGetActiveTitle, wintitle

	Dbg("RotateWinTitle: trying active window: " . wintitle )

	new := ""
	; First rotate if possible
	for i, w in windows {
		if ( w.title == wintitle ) {
			; found
			Dbg("RotateWinTitle: FOUND w.title: " . w.title )
			if ( i == windows.Length() ) {
				new := windows[1].title
			} else {
				new := windows[i+1].title
			}
			break
		}
	}

	; if not found, check regexes
	if ( new == "" ){
		for i, pat in init_strs {
			Dbg("RotateWinTitle: checking pattern: " . pat)
			if ( wintitle ~= pat ){
				; Initial name
				Dbg("  RotateWinTitle: FOUND!")
				new := windows[1].title
				break
			}
		}
	}

	; if found, set the title
	if ( new != "" ){
		Dbg("  RotateWinTitle: NEW TITLE: " . new )
		WinSetTitle, A,, %new%
	}

}


;=======================================
ActivateWin(wintitle)
; Activate and bring to foreground the window called wintitle.
{
	Dbg("ACTIVATE({})", wintitle)
	;WinActivate, %wintitle%
	WinGet, hWnd, ID, %wintitle%
	DllCall("SetForegroundWindow", UInt, hWnd)
}

;=======================================
FocusWin(wintitle)
; Focus the window called wintitle.
{
	global FocusPreDelay
	Dbg("FOCUS({})", wintitle)
	;NB: don't use ControlFocus; it causes Lotro to go to
	; foreground FPS and doesn't return to capped background FPS.
	; Send a WM_ACTIVATE message instead.
	;; ControlFocus, ,%wintitle%
	;; XXX: Ugh; now I need this or full text commands don't work

	; WM_ACTIVATE(1)
	SendMessage, 0x06, 1, , , %wintitle%
	if ( FocusPreDelay > 0 ) {
		Sleep, %FocusPreDelay%
	}
}

;=======================================
UnfocusWin(wintitle)
; Relinquish focus on the window called wintitle.
{
	global FocusPostDelay
	Dbg("UNFOCUS({})", wintitle)
	if ( FocusPostDelay > 0 ) {
		Sleep, %FocusPostDelay%
	}
	;; WM_ACTIVATE(0) to unfocus it
	SendMessage, 0x06, 0, , , %wintitle%
}


;==============================================================================
; Send functions

;=======================================
SendChat(wintitle, text)
; Send text to wintitle, using ControlFocus to focus into a text field.
{
	global SendDelay
	if ( wintitle != "" ){
		WinGetActiveTitle, awin
		if ( IsPrefix(wintitle, awin) ){
			; Foreground window (NB: prefix match)
			Dbg("SENDCHAT({}): {}", "ACTIVE:", wintitle, text)
			Send, %text%
		} else {
			; Background window
			Dbg("SENDCHAT({}): {}", wintitle, text)
			ControlFocus, ,%wintitle%
			ControlSend, , %text%, %wintitle%
			UnfocusWin(wintitle)		; send back to background 
		}
	} else {
		Dbg("SENDCHAT({}): {}", "ACTIVE", text)
		Send, %text%
	}
	if ( SendDelay > 0 ) {
		Sleep, %SendDelay%
	}
}


;=======================================
SendWin(wintitle, keys)
; Send keys to wintitle without an explicit keyboard focus.
; Keys are first expanded (so you can use +^! for Shift/Ctrl/Alt).
{
	global SendDelay
	keys := ExpandKeys(keys)
	if ( wintitle != "" ){
		WinGetActiveTitle, awin
		if ( IsPrefix(wintitle, awin) ){
			; Foreground window (NB: prefix match)
			Dbg("SEND({}): {}", "ACTIVE:", wintitle, keys)
			Send, %keys%
		} else {
			; Background window
			FocusWin(wintitle)
			Dbg("SEND({}): {}", wintitle, keys)
			ControlSend, , %keys%, %wintitle%
			UnfocusWin(wintitle)
		}
	} else {
		Dbg("SEND({}): {}", "ACTIVE", keys)
		Send, %keys%
	}
	if ( SendDelay > 0 ) {
		Sleep, %SendDelay%
	}
}
