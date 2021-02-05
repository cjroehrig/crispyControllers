"""American/EuroTruck Simulator Game Module

    To use:
        - Set controller type to wheel;
        - bind steering x,y to vJoy x,y
        - do NOT bind joystick look
        - edit the ETS2 profiles/<your_id>/controls.sii:
            ... input j_look_ud  ``             # ensure not bound
            ... input j_look_lr  ``             # ensure not bound
            ... mix trackiron    `trackir.device.active?1`      # default=ON
            ... mix trackiryaw   `-joy.rx?0`    # y axis is flipped
            ... mix trackirpitch `joy.ry?0`
            ... mix trackirroll  `joy.rz?0`
        ...  <disable other trackir stuff if an actual trackIR is present>
        # where joy is appropriate device (ie. joy, joy2, joy3, etc)
"""

from crispy.CJRPIEGame import CJRPIEGame
import os

# to allow JoystickTester, etc to use this file:
_mydir = __file__.split(os.path.sep)[-2]
if   _mydir == "EuroTrucks2":     _processName = "eurotrucks2"
elif _mydir == "AmerTrucks":      _processName = "amtrucks"
else: _processName = _mydir

class PIEGame(CJRPIEGame):
    ProcessName = _processName
    #RunInBackground = True          # XXX for testing...

    #=======================================
    def Init(self):

        # LOOK
        self.look = self.CJRLook()
        self.CJRLookAddTracker( self.look,
            smoothing=80,          # smoothing interval in ms
            scale = 2.8,            # scale multiplier at the origin (offset)
            accel = 0.25,           # percent of squared offset to add
            maxAccel = 1.5,         # Maximum acceleration factor
            )
        self.CJRLookAddMouse( self.look,
            scale=4.0,              # joy axis travel per mouse pixel
            accel=0.9,              # percent of squared movement to add
            maxAccel=5,             # Maximum acceleration factor
            )

        # STEER
        self.steer = self.CJRSteer()
        ## Left/Right Mouse
        self.CJRSteerAddLRMouse( self.steer,
            scale = 2.0,            # joy axis travel per mouse pixel
            accel = 1,              # percent of squared movement to add
            maxAccel = 4,           # Maximum acceleration factor
            decay = 5,              # seconds to decay to 10% of its value
            )
        ## Left/Right Keyboard
        self.CJRSteerAddLRKey( self.steer,
            incr = 25,              # percent axisMax per second
            accel = 0.4,            # percent of key hold time (ms) to add
            maxAccel = 7,           # Maximum acceleration factor
            decay = 0.8,            # seconds to decay to 10% of its value
            )
        ## Up/Down Keyboard (throttle/brake)
        self.CJRSteerAddUDKey( self.steer,
            incr = 25,              # percent axisMax per second
            accel = 0.4,            # percent of key hold time (ms) to add
            maxAccel = 7,           # Maximum acceleration factor
            decay = 0.5,            # seconds to decay to 10% of its value
            )
        self.CJRSteerUDThrottleBrake(self.steer)
        self.CJRInitMouseLook()

        # Initialize all internal values
        self.steer.Init()
        self.look.Init()
        #self.G.dbgon('MJLX')
        #self.G.printr(self)

    #============================================================
    def Activate(self):
        """Called when window becomes foreground"""
        #self.steer.Reset()     # reset steering (NO! CRASH! (the truck))
        #self.look.Reset()
        #self.steer.keyu.dbgKey()        # output new debug header
        pass
    #============================================================
    def Suspend(self):
        #self.look._Spit_dT()
        #self.steer._Spit_dT()
        pass

    #============================================================
    def Run(self):
        self.CJRHandleLookSteerToggles()
        self.steer.Run()
        self.look.Run()
