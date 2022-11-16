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
mappings.ahk			| The AutoHotKey key bindings and actions.  These are the keybindings that are intercepted and used to control the other window(s).
defs.ahk				| A wrapper to read the MODE file which tells which defs-*.ahk file to read.
LotroWin.ahk			| The LotroWin class which contains the logic for operating LotRO windows/characters.
bindingdef.ahk			| Key binding definitions in a dictionary (KK). These are the LotRO in-game keybindings used by LotroWin to control a window.
MODE					| a single word: DuoAH, DuoAA or Trio
### Setup definitions

File					| Description
----					| -----------
defs-DuoAH.ahk			| A duoboxed party of 2 (dps + heal).
defs-DuoAA.ahk			| A duoboxed party of 2 (dps + dps) [both are assists]
defs-Trio.ahk			| A trioboxed party of 3 (dps + heal + tank).

### Library files
File					| Description
----					| -----------
Lib/ahk/io.ahk			| I/O functions (that actually do the Windows calls).
Lib/ahk/util.ahk		| Utility functions.


## HOW TO GET STARTED:
1.	Install crispyControllers and AutoHotKey:  
	https://github.com/cjroehrig/crispyControllers

2.  Edit `mappings.ahk` and `bindingdef.ahk` to use your preferred key bindings, and `defs.ahk` with your preferred window sizes and resolutions.  NB: The examples here are set up to use ESDF instead of WASD.

	The `mappings.ahk` uses standard AutoHotKey mappings:  
	https://www.autohotkey.com/docs/Hotkeys.htm

	The `bindingdef.ahk` uses the format for the AutoHotKey `Send` command:  
	https://www.autohotkey.com/docs/commands/Send.htm  
	https://www.autohotkey.com/docs/KeyList.htm  

3.	For each toon, set up a dedicated ActionBar with slots for remote skills and assigned hotkeys. These are the skills that will be controlled by your other windows.  The default is `F1-F6`.  Those hotkeys are intercepted by mappings.ahk and sent to other windows;  this lets you assign `F1-F6` LotRO key bindings to control this ActionBar (they can only be triggered when the window is in the background).

4.  Edit your defs file (start with defs-DuoAH.ahk) to define each window and the skilltargets (see the defs-Trio.ahk for example) for each of your skills, and whether to use Target or Assist (skillassist) for each skill.  There should be a LotroWin for each multi-boxed character.

5.	Add Lotro to the crispyControllers `main.ahk`, update the `MODE` file according to which mode you will be playing and run AutoHotKey `main.ahk`.

6.	Log into each LotRO account/toon and use your Rotate Window Title key binding to set its window title to the correct title for that toon (as defined in your defs file).

7.	Party up so that each window has the fellowship members in the correct order.  This may be tricky for larger parties and you may need to redefine your defs to make it possible.

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

These files are automatically loaded using the layout_full() and
layout_win() functions.  I found it useful to have the following Combat options set in the `wbg` layout (but not in the foreground `w` and `f` layouts):
- Allow skill buttons to target nearest enemy
- Enable skill target forwarding
- Enable movement assistance in combat

For immersion, turn down all volume sliders for all your background toons except for the User Interface volume so you can hear any chat attempts in background windows (and Player Music so you can get some enhanced stereo effects).

To be effective in full-screen, your `F1-F6` skills should be ones which don't require knowledge of any "procs" which you can't see.   Cooldowns are ok -- you eventually get a sense of the timing.

I set up my `F1-F6` (remote) ActionBar to:
### DPS (Hunter):
1.	Splitshot
2.	Blindside
3.	Quick Shot
4.	Penetrating Shot
5.	Blood Arrow
6.	Merciful Shot

### HEAL (Minstrel):
1.	Still as Death
2.	Story of Courage
3.	Chord of Salvation
4.	Inspire Fellows
5.	Bolster Courage
6.	Triumphant Spirit (or Fellowship's Heart)

### TANK (Guardian):
1.	Stamp
2.	Challenge
3.	Guardian's Ward
4.	Vexing Blow
5.	Sweeping Cut
6.	Engage

