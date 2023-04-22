# crispyControllers

A framework and library for FreePIE and AutoHotKey with examples.
Feel free to use any code you find useful.

- FreePIE is a Python-based scripting engine for analog game controllers:  
	https://andersmalmgren.github.io/FreePIE/
- AutoHotKey is a keyboard remapping scripting engine:  
	https://autohotkey.com


### Features:
- multiple-file Python modules and modular per-game folders (also for AutoHotKey)
- automatic switching between games
- support for debugging with native Python (for better diagnostics)
- keyboard+mouse+headtracker to vjoy with acceleration, decay, smoothing, mouse steer/look toggle, accurate timing, etc

### Example Games:
Game						| Description
-------------------------	| -----------
EliteDangerous				| Smooth key/mouse and EDTracker
Euro Truck Simulator 2		| Smooth key/mouse and EDTracker
Lord of the Rings Online	| Multi-boxing with a mixed-class party (AHK).

### A Tour 
File						| Description
-------------------------	| -----------
main.py						| FreePIE main
main.ahk					| AutoHotKey main
Games/EuroTrucks2/game.py	| an example of the per-game code 
Lib/pylib/CJRPIEGame.py		| general axes setup functions for all my games
Lib/pylib/MouseJoy.py		| the keyboard/mouse/tracker to vJoy conversion
Lib/pylib/GameSwitcher.py	| the game switcher code


------------------------------------------------------------------------------
## Basic Usage
1.	Add your game code under the Games directory.  See existing examples.
2.	Add a line for your game in main.py or main.ahk as appropriate.
    (Comment-out or remove entries you are not using.)
3.	Run the main.py and/or main.ahk (in separate Terminals):

		freepie main.py

		ahk main.ahk

You can also run them using the GUIs once you have debugged things.
I generally leave AutoHotKey running all the time (but FreePIE needs to be restarted when re-plugging in the EDTracker).

NOTE: My examples use ESDF instead of WASD and assume a lot of
in-game bindings, so they almost certainly won't work for you without
modification.


------------------------------------------------------------------------------
## HOWTO INSTALL

NB: these notes are mainly for my own reminders, so you may want to do something differently.

1. OPTIONAL: Install the Cygwin UNIX environment: https://cygwin.com  
   This isn't required, but most of the install notes are in the form of
   bash scripts.  It shouldn't be too hard to figure out what they do if you
   want to skip this.

2. Unpack or git clone to ~/Documents/crispyControllers

3. Install the packages below.  (PF="Program Files")

4. OPTIONAL: Create symlinks for running AutoHotKey and Freepie from the command-line:

		ln -s "/cygdrive/c/Program Files/AutoHotkey/AutoHotkey.exe" ~/bin/ahk
		ln -s "../Documents/crispyControllers/INSTALL/bin/freepie" ~/bin/freepie


------------------------------------------------
## AutoHotkey
https://www.autohotkey.com/
- Update ./PKG with current installer
- Install to C:/$PF/AutoHotkey

		# XXX: Administrator is no longer needed:
		# To run as administrator:
		# AutoHotkey.exe (right-click) > Properties > Compatibility:
		#	 Run as Administrator

- You can create a Windows shortcut for AutoHotKey with:

Property Name		| Value
------------------- | -----
Target				| %UserProfile%\Documents\crispyControllers\main.ahk
Start In			| %UserProfile%\Documents\crispyControllers


------------------------------------------------
## vJoy (virtual joystick device for FreePIE)
http://vjoystick.sourceforge.net
- Update ./PKG with current installer
	> NB: (create wrapper dir with correct version number)
- Install with all defaults (to C:/$PF/vJoy) + driver)
- Configure:  Launch vJoyConf (in Start Menu)
	> XXX:  the default Joy 1 is fine for now.

------------------------------------------------
## FreePIE
https://andersmalmgren.github.io/FreePIE/

### OPTION 1: stock version
This does not include the GUI-less Console version which you might prefer if you want to run it from a terminal.

1. Download and install it to C:\Program Files (x86)

2. Create the required symlinks in the FreePIE/pylib directory (as Administrator):

		# XXX: untested  (Cygwin: prefix with cmd -c)
		mklink /d "C:\Program Files (x86)\FreePIE\pylib\Games" "%USERPROFILE%\Documents\crispyControllers\Games"
		mklink /d "C:\Program Files (x86)\FreePIE\pylib\crispy" "%USERPROFILE%\Documents\crispyControllers\Lib\pylib"

You can also create the links using the included bash script (NB: check it first):
		./INSTALL/mklinks.sh -F


### OPTION 2: my patched Console (and GUI) version
This version is compiled from a Jun 11 2020 (version 1.11.731.0) git snapshot and includes the FreePIE.Console.exe GUI-less version.   No guarantees.

Note that the Console version does not have a Windows event loop which may
cause problems with plugins that require it.   This version includes a patch to the Joystick plugin to get it to work.

1. Unzip ./INSTALL/FreePIE.zip into ./INSTALL/FreePIE/
2. Run the ./INSTALL/INSTALL-FreePIE.sh script (as Administrator). This will also create the required symlinks.  NB: check it first; it does no error-checking!

------------
### OPTION 3: Compile from source

NB: this was last done 2020 and may need to be updated.

To build the FreePIE Console version:

- You'll need Microsoft Visual Studio (I used 2019 Community Edition)
- Follow the directions in ./build/FreePIE/HOWTO_build.txt

- Once it is built, install as Administrator: ./INSTALL/INSTALL-FreePIE.sh			


------------------------------------------------
## Python
https://www.python.org/downloads/windows/

The FreePIE engine assumes your Python code is only in one file and
doesn't handle error reporting well for multiple files (and it doesn't
look easy to fix).  I'd recommended installing Python 3 for Windows to test your code with the included FreePIE simulator shims to get much better error diagnostics.


Python for Windows is recommended (instead of Cygwin python) in order to for GameSwitcher to work in the simulator.  You'll need to also install the pywin32 and psutil PIP modules (e.g. pip3 install pywin32)

Note that FreePIE uses the IronPython 2.7 engine so be wary of 2.7 vs 3.x issues.

------------------------------------------------
## EDTracker
https://hobbycomponents.com/electronics/440-diy-head-tracker-bundle

EDTracker is a kit-built Arduino Pro Micro and gyroscope-based head tracker that works pretty well (fast response but a bit spiky).

The Pro Micro and MPU-9250 are readily available from various places; I got a bunch more PCBs for insurance (the Pro Micro USB jack breaks off very easily). Leave out the button: crispyControllers includes a re-center function.

I also used these to make it reliable:
- Amphenol ICC MUSB-K552-30 robust micro-USB jack that just (barely) fits in the Hammond 1551 case.  Delicate soldering job with a .050 ribbon cable.
- 6" 90-degree micro-USB to female USB-A OTG cable ("port-saver")
- Weltool HB1 headlamp strap (with a 4x6" piece of 1/4" neoprene foam under the band) to hold the unit (if you don't have a headset to mount it to)
- GafferPower tape to secure it.

### EDTrackerGUI
https://github.com/brumster/EDTracker2
- Open EDTracker2-GUI-V4.0.4.zip from ./PKG/EDTracker
	and drag the EDTrackerUI404 folder to:
	C:/$PF/EDTrackerUI

- Settings: 
	- Yaw, Pitch scaling to 1.00 (or -1.00 to get correct orientation)
	- Smoothing: 0
	- Response Mode: Linear
	- do not enable hotkey
	- follow EDTracker guide to calibrate magnetometer (thoroughly!)
	- before each use: hold still for 20s and click Auto Gyro Bias

	

### arduino IDE (not needed)
https://arduino.cc
- download the .ZIP (non-admin install) version to PKG/EDTracker
	open the arduino-$VER-windows.zip file and drag the contained folder to:
	C:/$PF/arduino

#### EDTracker hardware def and libs:
https://github.com/brumster/EDTracker2_ArduinoHardware

	fixperm -G '/cygdrive/c/Program Files/arduino'		# as Administrator
		[icacls arduino /grant:r $LOGINSERVER\\$USERNAME:(OI)(CI)F]
	ed=./PKG/EDTracker/arduino/EDTracker2_ArduinoHardware-master/edtracker
	cp -a "$ed" '/cygdrive/c/Program Files/arduino/hardware'

