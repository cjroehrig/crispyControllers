"""No Man's Sky Game Module

    NMSSettings:
        XXX: this doesn't work - no vjoy/joystick support..
            - needs Xbox controller?
"""

from crispy.CJRPIEGame import CJRPIEGame
import os

# to allow JoystickTester, etc to use this file:
_mydir = __file__.split(os.path.sep)[-2]
if   _mydir == "NoMansSky":     _processName = "NMS"
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
        self.CJRInitMouseLook()

        # Initialize all internal values
        self.steer = None
        self.look.Init()
        #self.G.dbgon('MJLX')
        #self.G.printr(self)


    #============================================================
    def Activate(self):
        """Called when window becomes foreground"""
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
        self.look.Run()
