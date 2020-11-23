# crispyControllers
A scripting framework and library for AutoHotKey and FreePIE to make it
easy to add and manage keyboard, mouse and controller customizations to games
and other programs.

## Features:
	- Simple to set up new games.
	- Automatic game-switching.
	- Powerful mouse and key to joystick mapping (MouseJoy).
	- EDTracker support

#==============================================================================
# HOWTO INSTALL CJRControllers environment
# CJR Jun 2020
#

#==============================================================================
# AutoHotkey
	- Update PKG with current installer:
		https://www.autohotkey.com/
	- Install to C:/$PF/AutoHotkey

	# NB: Administrator no longer needed.
	# To run as administrator:
	# AutoHotkey.exe (right-click) > Properties > Compatibility:
	#    Run as Administrator

#==============================================================================
# vJoy (virtual joystick device for FreePIE)
	- Update PKG with current installer:
		http://vjoystick.sourceforge.net
		# (create wrapper dir with correct version number)
	- Install with all defaults (to C:/$PF/vJoy + driver)
	- Configure:  Launch vJoyConf (in Start Menu)
		# XXX:  suss
		- Joy 1:   POV/buttons?
		- Joy 2??

#==============================================================================
# FreePIE - console version, patched (cywgin)
	# OPTIONAL: rebuild; see build/FreePIE/HOWTO_build.txt

	# As Administrator:
	./INSTALL/INSTALL-FreePIE.sh			

#==============================================================================
# EDTracker
	## EDTrackerGUI
		- install EDTracker2-GUI-V4.0.4 from PKG/EDTracker to:
			C:/$PF/EDTracker2-GUI
		- ... 
	## arduino
	- download the .ZIP (non-admin install) version to PKG/EDTracker
	- Install to C:/$PF/arduino
	# install edtracker hardware def and libs:
		fixperm -G '/cygdrive/c/Program Files/arduino'		# as Administrator
		ed=./PKG/EDTracker/arduino/EDTracker2_ArduinoHardware-master/edtracker
		cp -a "$ed" '/cygdrive/c/Program Files/arduino/hardware'

