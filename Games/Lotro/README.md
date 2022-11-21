# LotRO multi-boxing crispyControllers/AutoHotKey configuration

## Overview
This is a set of AutoHotKey scripts for multi-boxing in LotRO with different classes.  It requires the crispyControllers framework.

It lets you play from within one full-screen window while controlling (in a limited fashion) another toon/class in a background window without breaking immersion by switching windows, etc.

It is symmetrical:  you can switch windows at any time to any of your other characters and control the others.

You can SELECT a fellow from your party and certain keys (F1-F6) are intercepted and used to send to that currently SELECTed fellow (each character should have bindings set aside for this use; it is recommended to use a separate "remote" action bar for this).   Each window has its own independent notion of its currently SELECTed fellow.

FOLLOW is a state you can turn on/off for your SELECTED fellow or for all fellows (independently).   Commands can apply to all FOLLOWing fellows or just your SELECTed FOLLOWing fellow.    See the mappings.akh file for examples.  Each window has its own independent FOLLOW states.

## The Files
NB: In AutoHotKey, there can be no definitions after the first mapping, so the crispyControllers framework keeps definitions and mappings in separate files.

File					| Description
----					| -----------
mappings.ahk			| The AutoHotKey key bindings and actions.  These are the hotkeys that are intercepted and used to control the other window(s).
defs.ahk				| Your Lotro configuration and more keybindings
LotroWin.ahk			| The LotroWin class which contains the logic for operating LotRO windows/characters.

## HOW TO GET STARTED:
1.	Install crispyControllers and AutoHotKey (FreePIE is not needed):
	https://github.com/cjroehrig/crispyControllers


2.  Edit `mappings.ahk` and `defs.ahk` to use your preferred key bindings and your preferred window sizes and resolutions.  NB: The examples here are set up to use ESDF instead of WASD.

	The `mappings.ahk` assignments use standard AutoHotKey hotkey notation:  
	https://www.autohotkey.com/docs/Hotkeys.htm

	`bindingdef.ahk` and all function calls use the curly-brace `Send` notation:
	https://www.autohotkey.com/docs/commands/Send.htm  
	https://www.autohotkey.com/docs/KeyList.htm  

3.	For each toon, set up a dedicated ActionBar with slots for remote skills and assigned hotkeys. These are the skills that will be controlled by your other windows.  The default is `F1-F6`.  Those hotkeys are intercepted by mappings.ahk and sent to other windows;  this lets you assign `F1-F6` LotRO key bindings to control this ActionBar (they can only be triggered when the window is in the background).

5.	Add Lotro to the crispyControllers `main.ahk` (uncomment it if not already).

6.	Log into each LotRO toon and use your RotateName key binding to set its window title to the correct role for that toon (DPS/HEAL/TANK).   (You can add your own sets of roles by editing the defs-* files.)

7.	Party up and use the RotateParty key binding to match each window's party in the titlebar with its actual party order.  You can party with other players, but your LotroWin fellows must be partied-up first (they must have the first party slots).

8.	SELECT your background toon, turn FOLLOW on, and try out the various FOLLOW commands.  Run autohotkey in a terminal window to get lots of diagnostic info about what is happening.



## NOTES AND TIPS

To debug under a Cygwin terminal:
```
	ln -s /cygdrive/c/Program Files/AutoHotkey/AutoHotkey.exe ~/bin/ahk
	ahk main.ahk
	# use the AutoHotkey Tray icon to exit
```

Run LotRO as Full-Screen (Windowed) instead of Full-screen to make
window-switching faster.

Save your UI (`/ui layout save <file>`) as:

`<file>` | Description
------ | -----------
f | Full screen layout.
w | Windowed layout.
wbg | Background window layout.

These files are automatically loaded using the LayoutFullScreen() and
LayoutWindowed() functions.  I found it useful to have the following Combat options set in the `wbg` layout (but not in the foreground `w` and `f` layouts):
- Allow skill buttons to target nearest enemy
- Enable skill target forwarding
- Enable movement assistance in combat

For immersion, turn down all volume sliders for all your background toons except for the User Interface volume so you can hear any chat attempts in background windows (and Player Music so you can get some enhanced stereo effects).

To be effective in full-screen, your `F1-F6` skills should be ones which don't require knowledge of any "procs" which you can't see.   Cooldowns are ok -- you eventually get a sense of the timing.

I set up my `F1-F6` (remote) ActionBar to:
### DPS (Red Hunter):
1.	Purge Poison
2.	Upshot
3.	Quick Shot
4.	Swift Bow
5.	Merciful Shot
6.	Heart Seeker

### HEAL (Blue Minstrel):
1.	Story of Courage
1.	Solioquy of Spirit
3.	Chord of Salvation
4.	Inspire Fellows
5.	Bolster Courage
6.	Triumphant Spirit (or Fellowship's Heart)

### TANK (Guardian):
1.	Ignore the Pain
2.	Stamp
3.	Guardian's Ward
4.	Vexing Blow
5.	Sweeping Cut
6.	Challenge
