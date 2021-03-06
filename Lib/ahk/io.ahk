; I/O Functions
; This is the only file that should actually result in Windows calls

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
	Dbg("ACTIVATE " . wintitle)
	;WinActivate, %wintitle%
	WinGet, hWnd, ID, %wintitle%
	DllCall("SetForegroundWindow", UInt, hWnd)
}

;=======================================
FocusWin(wintitle)
; Focus the window called wintitle.
{
	global FocusPreDelay
	Dbg("FOCUS " . wintitle)
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
	Dbg("UNFOCUS " . wintitle)
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
; NB: this can cause win to execute with foreground 60 FPS.
{
	global SendDelay
	if ( wintitle != "" ){
		WinGetActiveTitle, awin
		if ( wintitle != awin ){
			; Background window
			Dbg("SENDCHAT({}) : {}", wintitle, text)
			ControlFocus, ,%wintitle%
			ControlSend, , %text%, %wintitle%
		} else {
			Dbg("SENDCHAT({}) : {}", "ACTIVE:".wintitle, text)
			Send, %text%
		}
	} else {
		Dbg("SENDCHAT({}) : {}", "ACTIVE", text)
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
		if ( wintitle != awin ){
			; Background window
			FocusWin(wintitle)
			Dbg("SEND({}) : {}", wintitle, keys)
			ControlSend, , %keys%, %wintitle%
			UnfocusWin(wintitle)
		} else {
			Dbg("SEND({}) : {}", "ACTIVE:".wintitle, keys)
			Send, %keys%
		}
	} else {
		Dbg("SEND({}) : {}", "ACTIVE", keys)
		Send, %keys%
	}
	if ( SendDelay > 0 ) {
		Sleep, %SendDelay%
	}
}
