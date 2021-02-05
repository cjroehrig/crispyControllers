"""Elite Dangerous Game Module

    ED Settings:
        - Turn Headlook Smoothing ON
            - otherwise leaving panels won't animate (BUG)
        - Set all axes deadzones to none; sensitivities to lowest
        - Need to manually edit Custom.3.0.binds To bind Roll:
            RollAxisRaw:
            BuggyRollAxisRaw:
            RollCamera:
                <Binding Device="vJoy" Key="Joy_ZAxis" />

    Extra Bindings:
"""

from crispy.CJRPIEGame import CJRPIEGame
import os

# to allow JoystickTester, etc to use this file:
_mydir = __file__.split(os.path.sep)[-2]
if   _mydir == "EliteDangerous":     _processName = "EliteDangerous64"
else: _processName = _mydir

class PIEGame(CJRPIEGame):
    ProcessName = _processName
    #RunInBackground = True          # XXX for testing...

    #=======================================
    def Init(self):

        # LOOK
        self.look = self.CJRLook()
        self.CJRLookAddTracker( self.look,
            #smoothing=160,         # use ED's native smoothing instead
            scale = 1.5,            # scale multiplier at the origin (offset)
            accel = 2.40,           # percent of squared offset to add
            maxAccel = 9.8,         # Maximum acceleration factor
            )
        self.CJRLookAddMouse( self.look,
            scale=8.0,              # joy axis travel per mouse pixel
            accel=1.0,              # percent of squared movement to add
            maxAccel=5,             # Maximum acceleration factor
            )

        # STEER
        self.steer = self.CJRSteer()
        ## Left/Right/Up/Down Mouse
        self.CJRSteerAddLRUDMouse( self.steer,
            scale = 20.0,           # joy axis travel per mouse pixel
            accel = 0.8,            # percent of squared movement to add
            maxAccel = 5,           # Maximum acceleration factor
            decay = 20,             # seconds to decay to 10% of its value
            )
        ## Roll left/right: S/F keys
        self.CJRSteerAddRollKey( self.steer,
            incr = 20,              # percent axisMax per second
            accel = 5.0,            # percent of key hold time (ms) to add
            maxAccel = 70,          # Maximum acceleration factor
            decay = 0.8,            # seconds to decay to 10% of its value
            )

        self.CJRInitMouseLook()

        # Initialize all internal values
        self.steer.Init()
        self.look.Init()
        #self.G.dbgon('MJLX')
        #self.G.printr(self)


    #============================================================
    def Activate(self):
        """Called when window becomes foreground"""
        self.steer.Reset()
        self.look.Reset()
        #self.steer.keyu.dbgKey()        # output new debug header

    #============================================================
    def Suspend(self):
        #self.look._Spit_dT()
        #self.steer._Spit_dT()
        pass

    #============================================================
    def Run(self):
        self.CJRHandleLookSteerToggles(reset=True)
        self.steer.Run()
        self.look.Run()
