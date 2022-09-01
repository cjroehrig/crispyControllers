# crispyControllers

A framework and library for FreePIE and AutoHotKey with examples.

(FreePIE is a Python-based scripting engine for analog game controllers.
AutoHotKey is a keyboard remapping scripting engine.)

This is in a fairly rough state but hopefully useable.
Let me know if you are having issues and I'll try to help.

Updated: CJR Jun 2020

### Features:
- Separate directories for each game and automatic switching between games.
- mouse/keyboard to joystick mapping with lots of options.
- EDTracker head tracking support.

### Example Games:

Game						| Description
-------------------------	| -----------
Lord of the Rings Online	| Multi-boxing with a mixed-class party (AHK).
Euro Truck Simulator 2		| Smooth key/mouse and EDTracker
American Truck Simulator	| Smooth key/mouse and EDTracker
EliteDangerous				| Smooth key/mouse and EDTracker

------------------------------------------------------------------------------
## Basic Usage
1.	Add your game code under the Games directory.  See existing examples.
2.	Add a line for your game in main.py or main.ahk as appropriate.
    (Comment-out or remove entries you are not using.)
3.	Run the main.py and/or main.ahk (in separate Terminals):

		freepie main.py

		ahk main.ahk | cat

You can also run them using the GUIs once you have debugged things.

NOTE: The existing examples use ESDF instead of WASD and assume a lot of
in-game bindings, so they almost certainly won't work for you without
modification.


------------------------------------------------------------------------------
## HOWTO INSTALL

1. Install the Cygwin UNIX environment (https://cygwin.com) if you
   haven't already and launch a terminal.
   This isn't strictly required, but most of the install
   notes are in the form of bash scripts.   You'll probably have
   trouble if you're not familiar with bash.

2. Unpack to ~/Documents/crispyControllers

3. IMPORTANT:  review, understand and modify appropriately all
install scripts before you run them!  I've tried to keep things general,
but may have missed a hard-coded path here and there.

4. Create symlinks for running AutoHotKey and Freepie from the command-line:

		ln -s "/cygdrive/c/Program Files/AutoHotkey/AutoHotkey.exe" ~/bin/ahk
		ln -s "../Documents/crispyControllers/INSTALL/bin/freepie" ~/bin/freepie

5. Install the packages below.  (PF="Program Files")


------------------------------------------------
## AutoHotkey
- Update ./PKG with current installer:
	https://www.autohotkey.com/
- Install to C:/$PF/AutoHotkey

		# NB: The following (Administrator) is no longer needed:
		# To run as administrator:
		# AutoHotkey.exe (right-click) > Properties > Compatibility:
		#	 Run as Administrator

------------------------------------------------
## vJoy (virtual joystick device for FreePIE)
- Update ./PKG with current installer:
	http://vjoystick.sourceforge.net
	> NB: (create wrapper dir with correct version number)
- Install with all defaults (to C:/$PF/vJoy + driver)
- Configure:  Launch vJoyConf (in Start Menu)
	> XXX:  update this once I add more games...
	- Joy 1:   POV/buttons?
	- Joy 2??

------------------------------------------------
## FreePIE - console version, patched (cywgin)
The stock FreePIE GUI might work except it is much easier to debug your
python code with the Console version which is not included in the FreePIE
distribution.

The FreePIE engine assumes your Python code is only in one file and
doesn't handle error reporting well for multiple files (and it doesn't
look easy to fix).  Therefore, it is highly recommended to install 
Python 3 for Windows to test your code with the included FreePIE
simulator shims to get much better error diagnostics.
(Note that FreePIE uses the IronPython 2.7 engine so be wary of 2.7 vs
3.0 issues.  You may also want to install Python 2.7 (cygwin version).


To build the FreePIE Console version:

- You'll need Microsoft Visual Studio (e.g. 2019 Community Edition)
- Follow the directions in:

		build/FreePIE/HOWTO_build.txt

- Once it is built, as Administrator:

		./INSTALL/INSTALL-FreePIE.sh			

I've included a pre-build Console (and GUI) version in:

		INSTALL/FreePIE.zip

Unzip it to INSTALL/FreePIE to use the INSTALL-FreePIE.sh script.


Note that the Console version does not have a Windows event loop which may
cause problems with plugins that require it.   My HOWTO_build instructions
includes a patch to the Joystick plugin to get it to work in the Console
version.

------------------------------------------------
## EDTracker
### EDTrackerGUI
- Open EDTracker2-GUI-V4.0.4.zip from ./PKG/EDTracker
	and drag the EDTrackerUI404 folder to:
	C:/$PF/EDTrackerUI

### arduino
- download the .ZIP (non-admin install) version to PKG/EDTracker
	open the arduino-$VER-windows.zip file and drag the contained folder to:
	C:/$PF/arduino

### EDTracker hardware def and libs:
	fixperm -G '/cygdrive/c/Program Files/arduino'		# as Administrator
		[icacls arduino /grant:r $LOGINSERVER\\$USERNAME:(OI)(CI)F]
	ed=./PKG/EDTracker/arduino/EDTracker2_ArduinoHardware-master/edtracker
	cp -a "$ed" '/cygdrive/c/Program Files/arduino/hardware'
