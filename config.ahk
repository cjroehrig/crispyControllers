;===============================================================================
; Config 

;#Warn All, StdOut		; for debugging; (but doesn't work)
#Warn All
#Warn LocalSameAsGlobal, Off

#SingleInstance

;#InstallMouseHook

#InstallKeybdHook
#UseHook On
SendMode Input

; Don't send spurious Ctrl !
#MenuMaskKey vkE8

; Lotro doesn't accept keystrokes unless it is active/has focus
; so we need to use ControlFocus; this sets delay (ms) to wait after 
; setting focus before sending keystroke.  Default = 20ms
;SetControlDelay 0
SetControlDelay 20

; Lotro sometimes drops keys when sending long chat strings
;  SetKeyDelay Delay, PressDuration   # values in ms
SetKeyDelay, 10, 10

; Delay after WinActivate (Default=100ms)
SetWinDelay 100
#WinActivateForce

; key repeat limit
#MaxHotkeysPerInterval 200

SetTitleMatchMode 1		; leading match for window titles

StringLower, Hostname, A_ComputerName

switch Hostname
{
	case "aquila":
		FullScreen := { width:2560, height: 1440 }
	default:
		FullScreen := { width:1920, height: 1080 }
}

;===============================================================================
; io Config
#Include Lib/ahk/io.ahk

;; delay between Sends (needed to avoid some Lotro WarSteed dismount bugs)
SendDelay = 10

;; delays between ControlFocus and sends
FocusPreDelay = 1
FocusPostDelay = 1
