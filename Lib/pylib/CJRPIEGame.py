"""CJRPIEGame

    A subclass of PIEGame that uses MouseJoy to implement my standard
    mouse/key look/steer and head tracking bindings.

    Provides various functions to set up my preferred mappings.

    Bindings Used:
        ## Axes:
        vjoy.RX, RY             Look (tracker/mouse)
        vjoy.X, Y               Steer (yaw/pitch or l-r/throttle-brake)
        vjoy.Z                  Roll (keyboard)
        ## Key Bindings
        E,S,D,F                 up/down/left/right steering
        S,F                     Roll left/right (with accel)
        MiddleMouse             MouseLook toggle + tracker centering
        Ctrl-MiddleMouse        Mouse steer on/off
        Alt-MiddleMouse         Tracker on/off

    Instance variables:
        myhost                  hostname for host-specific config
        steer                           MouseJoy
            .left,right,up,down         MJAxis
            .throttle,brake             == up,down (MJAxis)
                .key                    MJButtonUpdater
                .mouse                  MJMouseUpdater
            .lroll,rroll                MJAxis (for roll)
                .key                    MJMouseUpdater
        look                            MouseJoy
            .x, y                       MJAxis
                .mouse                  MJMouseUpdater
                .tracker                MJTrackerUpdater
        tracker                         EDTracker
            .{x,y}_smoother             MovingAvgSmoother
"""

#===============================================================================
__copyright__ = """
Copyright 2020 Chris Roehrig <croehrig@crispart.com>

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
"""

#===============================================================================

from crispy.PIEGame import PIEGameClass
from crispy.MouseJoy import *
from crispy.EDTracker import EDTracker
from crispy.Smoother import *
import socket

class CJRPIEGame (PIEGameClass):
    #=======================================
    def __init__(self, G):
        super(CJRPIEGame, self).__init__(G)
        self.look = None
        self.steer = None
        self.tracker = None
        self.trackEnabled = False

        self.myhost = socket.gethostname()   # for host-specific config


    #==========================================================================
    # LOOK

    #=======================================
    def CJRLook(self):
        """Return a look target on vJoy0:RX,RY."""
        look = MouseJoy(self.G, 0)
        look.name = "LOOK"
        look.x = look.CreateAxis('RX', 'MJLX')
        look.y = look.CreateAxis('RY', 'MJLY')
        look.mouseEnabled = False
        look.trackerEnabled = False
        return look

    #=======================================
    def CJRLookAddMouse(self, look,
            scale = 8.0,        # joy axis travel per mouse pixel
            accel = 1.0,        # percent of squared movement to add
            maxAccel = 5,       # Maximum acceleration factor
            ):
        """Add mouse look to MouseJoy target 'look'."""
        u = MJMouseUpdater()
        u.scale = scale
        u.accel = accel
        u.maxAccel = maxAccel
        u.decay = None          # no decay
        look.x.mouse = u
        look.y.mouse = u.Copy()
        look.x.AddUpdater(look.x.mouse)
        look.y.AddUpdater(look.y.mouse)
        look.mouseEnabled = True
        self.G.printf("CJR: %s: added mouse", look.name )

    #=======================================
    def CJRLookAddTracker(self, look,
            scale = 2.8,        # scale multiplier at the origin (offset)
            accel = 0.25,       # percent of squared offset to add
            maxAccel = 1.5,     # Maximum acceleration factor
            smoothing=None,     # smoothing interval in ms (*)
            ):
        """Add head tracking to MouseJoy target 'look'.

           (*) smoothing interval is only approximate:
           'smoothing' is divided by executionInterval to get the
           number of samples.
           NB: ExecutionInterval=1 actually takes 2.1ms on my PC and
           only starts to converge to real-time at around 5-10ms.
           (This can be measured by using TimingTester() in main.py.)
           So with the default ExecutionInterval=1, the smoothing interval is
           only about half the value given.
        """
        G = self.G
        # Get EDtracker if attached
        self.tracker = EDTracker(G, axisMax=look.x.maxVal)
        if not self.tracker.edjoy:
            self.tracker = None
            return

        # Smoothing
        if smoothing:
            N = int(smoothing / G.system.threadExecutionInterval)
            self.tracker.x_smoother = MovingAvgSmoother(G, N)
            self.tracker.x_smoother.name = "EDTrackX"
            self.tracker.y_smoother = MovingAvgSmoother(G, N)
            self.tracker.y_smoother.name = "EDTrackY"

        # Updaters and defaults
        u = MJTrackerUpdater(self.tracker)
        u.scale = scale
        u.accel = accel
        u.maxAccel = maxAccel
        u.decay = None          # seconds to decay to 1% of its value
        look.x.tracker = u
        look.y.tracker = u.Copy()
        look.x.AddUpdater(look.x.tracker)
        look.y.AddUpdater(look.y.tracker)
        look.trackerEnabled = True

        # ardea's EDTracker uses the pre-made board which is upside-down :/
        # if self.myhost == 'ardea': look.y.tracker.scale *= -1.0
        # Post musambi-rebuild; both need inversion:
        look.y.tracker.scale *= -1.0

        self.G.printf("CJR: %s: added tracker", look.name )



    #==========================================================================
    # STEER

    #=======================================
    def CJRSteer(self):
        """Return a steer target on vJoy0"""
        steer = MouseJoy(self.G, 0)
        steer.name = "STEER"
        steer.mouseEnabled = False

        # possible axes...
        steer.left = None
        steer.right = None
        steer.up = None
        steer.down = None
        steer.throttle = None
        steer.brake = None
        steer.lroll = None
        steer.rroll = None
        return steer

    #=======================================
    def CJRSteerLR(self, steer):
        """Create left/right steering axes on 'steer'.X"""
        (steer.left, steer.right) = steer.CreateAxisPair('X', 'MJSX')
        steer.left.name = "LEFT"
        steer.right.name = "RIGHT"

    #=======================================
    def CJRSteerUD(self, steer):
        """Create up/down steering axes on 'steer'.Y"""
        (steer.up, steer.down) = steer.CreateAxisPair('Y', 'MJSY')
        steer.up.name = "LEFT"
        steer.down.name = "RIGHT"

    #=======================================
    def CJRSteerAddLRMouse(self, steer,
            scale = 2.0,        # joy axis travel per mouse pixel
            accel = 1,          # percent of squared movement to add
            maxAccel = 4,       # Maximum acceleration factor
            decay = 5,          # seconds to decay to 10% of its value
            ):
        """Add left/right mouse steering to steer.X."""
        if not steer.left:
            self.CJRSteerLR(steer)
        u = MJMouseUpdater()
        u.scale = scale
        u.accel = accel
        u.maxAccel = maxAccel
        u.decay = decay
        steer.left.mouse = u
        steer.right.mouse = u.Copy()
        steer.left.AddUpdater(steer.left.mouse)
        steer.right.AddUpdater(steer.right.mouse)
        steer.mouseEnabled = True
        self.G.printf("CJR: %s: added LR mouse", steer.name )

    #=======================================
    def CJRSteerAddUDMouse(self, steer,
            scale = 2.0,        # joy axis travel per mouse pixel
            accel = 1,          # percent of squared movement to add
            maxAccel = 4,       # Maximum acceleration factor
            decay = 5,          # seconds to decay to 10% of its value
            ):
        """Add up/down mouse steering to steer.Y."""
        if not steer.up:
            self.CJRSteerUD(steer)
        u = MJMouseUpdater()
        u.scale = scale
        u.accel = accel
        u.maxAccel = maxAccel
        u.decay = decay
        steer.up.mouse = u
        steer.down.mouse = u.Copy()
        steer.up.AddUpdater(steer.up.mouse)
        steer.down.AddUpdater(steer.down.mouse)
        steer.mouseEnabled = True
        self.G.printf("CJR: %s: added UD mouse", steer.name )

    #=======================================
    def CJRSteerAddLRUDMouse(self, *args, **kwargs):
        """Add left/right/up/down mouse steering to steer.X,Y."""
        self.CJRSteerAddLRMouse(*args,**kwargs)
        self.CJRSteerAddUDMouse(*args,**kwargs)

    #=======================================
    def CJRSteerAddLRKey(self, steer,
            incr = 25,          # percent axisMax per second
            accel = 0.4,        # percent of key hold time (ms) to add
            maxAccel = 7,       # Maximum acceleration factor
            decay = 0.8,        # seconds to decay to 10% of its value
            ):
        """Add left/right keyboard steering to steer.X."""
        if not steer.left:
            self.CJRSteerLR(steer)
        u = MJButtonUpdater()
        u.incr = incr
        u.accel = accel
        u.maxAccel = maxAccel
        u.decay = decay
        u.doubleTapThreshold = 0    # double-tap disabled for LR steering
        #u.doubleTapMaxAccel = True # Use max accel 
        u.multiTapThreshold = 0.120 # in seconds
        u.multiButtonAccel = True      # accel uses hold-time of any axis keys.

        steer.left.keyu = u
        steer.right.keyu = u.Copy()
        steer.left.AddUpdater(steer.left.keyu)
        steer.right.AddUpdater(steer.right.keyu)

        # my key bindings: S/F
        steer.left.keyu.setButton(self.G.Key.S)
        steer.right.keyu.setButton(self.G.Key.F)
        self.G.printf("CJR: %s: added LR keys", steer.name )

    #=======================================
    def CJRSteerAddUDKey(self, steer,
            incr = 25,          # percent axisMax per second
            accel = 0.4,        # percent of key hold time (ms) to add
            maxAccel = 7,       # Maximum acceleration factor
            decay = 0.5,        # seconds to decay to 10% of its value
            ):
        """Add up/down keyboard mapping to steer.Y."""

        if not steer.up:
            self.CJRSteerUD(steer)
        u = MJButtonUpdater()
        u.incr = incr
        u.accel = accel
        u.maxAccel = maxAccel
        u.decay = decay
        u.doubleTapThreshold = 0.120  # in seconds

        steer.up.keyu = u
        steer.down.keyu = u.Copy()
        steer.up.AddUpdater(steer.up.keyu)
        steer.down.AddUpdater(steer.down.keyu)

        # my key bindings: E/D
        steer.up.keyu.setButton(self.G.Key.E)
        steer.down.keyu.setButton(self.G.Key.D)
        self.G.printf("CJR: %s: added UD keys", steer.name )

    #=======================================
    def CJRSteerAddUDMouseWheel(self, steer,
            incr = 2,           # percent axisMax per click
            ):
        """Add up/down mousewheel mapping to steer.Y."""

        if not steer.up:
            self.CJRSteerUD(steer)
        u = MJOneShotUpdater()
        u.incr = incr

        steer.up.wheelu = u
        steer.down.wheelu = u.Copy()
        steer.up.AddUpdater(steer.up.wheelu)
        steer.down.AddUpdater(steer.down.wheelu)

        # my bindings: WHEELUP, WHEELDOWN  NB: I use FlipWheel in Windows
        steer.up.wheelu.setButton('WHEELDOWN')
        steer.down.wheelu.setButton('WHEELUP')
        self.G.printf("CJR: %s: added UD MouseWheel", steer.name )


    #=======================================
    def CJRSteerUDThrottleBrake(self, steer):
        """Set up/down steering axis to throttle/brake.
           Creates convenience variables and names.
        """
        steer.throttle = steer.up         # NB: by reference
        steer.brake = steer.down
        steer.throttle.name = "THROTTLE"  # NB: overwrites "UP", "DOWN"
        steer.brake.name = "BRAKE"
        steer.throttle.arrest = True      # throttle instantly zeros braking
        steer.brake.arrest = True         # braking instantly zeros throttle
        self.G.printf("CJR: %s: UD is throttle/brake", steer.name )


    #=======================================
    def CJRSteerRoll(self, steer):
        """Create left/right roll steering axes on 'steer'.Z"""
        (steer.lroll, steer.rroll) = steer.CreateAxisPair('Z', 'MJSZ')
        steer.lroll.name = "LROLL"
        steer.rroll.name = "RROLL"

    #=======================================
    def CJRSteerAddRollKey( self, steer,
            incr=20.0,      # percent axisMax per second
            accel=5.0,      # percent of key hold time (ms) to add
            maxAccel=70,    # Maximum acceleration factor
            decay=0.8,      # seconds to decay to 10% of its value
            ):
        """Add roll left/right with S/F keys on Z axis."""

        if not steer.lroll:
            self.CJRSteerRoll(steer)
        u = MJButtonUpdater()
        u.incr = incr
        u.accel = accel
        u.maxAccel = maxAccel
        u.decay = decay
        u.doubleTapThreshold = 0     # disable double-tap
        #u.doubleTapMaxAccel = True   # Use max accel
        u.multiTapThreshold = 0.120  # in seconds
        u.multiButtonAccel = True       # accel uses hold-time of any axis keys.

        steer.lroll.keyu = u
        steer.rroll.keyu = u.Copy()
        steer.lroll.AddUpdater(steer.lroll.keyu)
        steer.rroll.AddUpdater(steer.rroll.keyu)

        # Key Bindings
        steer.lroll.keyu.setButton(self.G.Key.S)
        steer.rroll.keyu.setButton(self.G.Key.F)
        self.G.printf("CJR: %s: added LR roll keys", steer.name )


    #==========================================================================
    # MouseLook 

    #=======================================
    def CJRInitMouseLook(self):
        """Set the default MouseLook state:
           MouseSteering if tracker is active; MouseLook otherwise."""
        if self.tracker:
            if self.steer:
                self.steer.mouseEnabled = True
            self.look.mouseEnabled = False
            self.look.trackerEnabled = True
            self.trackEnabled = True
            self.G.printf("CJR: Mouselook OFF (using tracker)")
        else:
            if self.steer:
                self.steer.mouseEnabled = False
            self.look.mouseEnabled = True
            self.look.trackerEnabled = False
            self.trackEnabled = False
            self.G.printf("CJR: Mouselook ON (no tracker)")



    #=======================================
    def CJRToggleMouseLook(self, reset=False, offset=True):
        """Toggle mouse look/steer.
           If reset is True, then the turned-off axis is reset when toggling.
        """

        if self.look.mouseEnabled:
            self.G.printf("MouseLook OFF")
            self.look.mouseEnabled = False
            self.steer.mouseEnabled = True
            if self.tracker and self.trackEnabled:
                self.look.trackerEnabled = True
                # reset/center tracker when leaving mouseLook
                self.tracker.Center()
                # Capture mouselook position as offset  
                if offset:
                    self.look.x.tracker.CaptureOffset()
                    self.look.y.tracker.CaptureOffset()
            if reset:
                self.look.Reset()
        else:
            self.G.printf("MouseLook ON")
            self.look.mouseEnabled = True
            self.look.trackerEnabled = False
            self.steer.mouseEnabled = False
            if reset:
                self.steer.Reset()



    #=======================================
    def CJRHandleLookSteerToggles(self,
            reset=False,
            offset=True,
            ):
        """Handle look/steer toggle/on/off keys.
           If reset is True then the axes are Reset() when toggling."""

        # Middle mouse -- toggle mouseLook
        if self.G.mouse.getPressed(2):
            if self.look and self.G.keyboard.getKeyDown(self.G.Key.LeftAlt):
                # Alt-MiddleMouse == toggle tracker on/off
                if self.trackEnabled:
                    self.trackEnabled = False
                    self.look.trackerEnabled = False
                else:
                    self.trackEnabled = True
                    if not self.look.mouseEnabled:
                        self.look.trackerEnabled = True
                self.G.printf("trackerEnabled: %s", self.look.trackerEnabled)

            elif (self.steer and
                        self.G.keyboard.getKeyDown(self.G.Key.LeftControl)):
                # Ctrl-MiddleMouse == toggle mouse steering on/off
                self.steer.mouseEnabled = not self.steer.mouseEnabled
                if reset:
                    self.steer.Reset()
                self.G.printf("mouseSteer: %s", self.steer.mouseEnabled)

            elif self.steer and self.look:
                # MiddleMouse == toggle Mouse Look/steer
                self.CJRToggleMouseLook(reset, offset)
