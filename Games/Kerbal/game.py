"""Kerbal Space Program Game Module

    Mouse steering for fine control

    Axes
        Yaw/Pitch (X/Y)     - mouse; absolute, no decay
    Bindings:
        Alt-MMB             - mouse steer on/off toggle (default: off)
        MMB                 - recenter at cursor

    Settings:
        - best to Hand-edit settings.cfg:
                ALL:
                    name = vJoy - Virtual Joystick
                    sensitivity = 1.0
                    deadzone = 0
                    scale = 1
                AXIS_PITCH:         axis = 1        inv = True
                AXIS_YAW:           axis = 0
                # AXIS_ROLL:          axis = 2      DON'T USE
                    - Don't use roll; use in-game keys/precision/etc.
        - don't bother with AXIS_CAMERA_HDG and AXIS_CAMERA_PITCH
            - terrible rate-based joystick-centric; doesn't work.
            - stick with in-game mouselook
"""

from crispy.CJRPIEGame import CJRPIEGame
import os

# to allow JoystickTester, etc to use this file:
_mydir = __file__.split(os.path.sep)[-2]
if   _mydir == "Kerbal":     _processName = "KSP_x64"
else: _processName = _mydir

class PIEGame(CJRPIEGame):
    ProcessName = _processName
    #RunInBackground = True          # XXX for testing...

    #=======================================
    def Init(self):

        # STEER
        self.steer = self.CJRSteer()

        ## Left/Right/Up/Down Mouse
        scale = 25      # horizontal
        self.CJRSteerAddLRMouse( self.steer,
            scale = scale,           # joy axis travel per mouse pixel
            accel = 0.0,            # percent of squared movement to add
            maxAccel = 10,           # Maximum acceleration factor
            decay = 0,             # seconds to decay to 10% of its value
            )
        self.CJRSteerAddUDMouse( self.steer,
            scale = scale*1.5,      # increase scale for vertical screen
            accel = 0.0,            # percent of squared movement to add
            maxAccel = 10,           # Maximum acceleration factor
            decay = 0,             # seconds to decay to 10% of its value
            )
        self.steer.mouseEnabled = False
        # Initialize all internal values
        self.steer.Init()
        #self.G.dbgon('MJLX')
        #self.G.printr(self)


    #============================================================
    def Activate(self):
        """Called when window becomes foreground"""
        self.steer.Reset()
        self.steer.mouseEnabled = False
        #self.steer.key.dbgKey()        # output new debug header

    #============================================================
    def Suspend(self):
        #self.look._Spit_dT()
        #self.steer._Spit_dT()
        pass

    #============================================================
    def Run(self):
        if self.G.mouse.getPressed(2):
            # MMB:  reset/zero
            if self.G.keyboard.getKeyDown(self.G.Key.LeftControl):
                # Alt-MMB toggle mouse steer on/off
                self.steer.mouseEnabled = not self.steer.mouseEnabled
            self.steer.Reset()

        # Don't mouse-steer if MMB or RMB is held (camera pan/rotate):
        if not self.G.mouse.getButton(1) and not self.G.mouse.getButton(2):
            self.steer.Run()
