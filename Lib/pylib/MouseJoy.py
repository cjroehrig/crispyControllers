# MouseJoy
"""MouseJoy  - mouse and key to vJoy joystick with lots of features.
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

class MJUpdater(object):
    """A strategy for updating an axis."""
    def __init__(self):
        """Constructor. Return a MJUpdater."""
        self.axis = None
        self.target = None
        self.G = None
        # Typical parameters
        self.scale = 1
        self.decay = 0              # Decay (seconds to decay to 1% of value)
        self.accel = 0
        self.maxAccel = 5
        self.incr = 0
        self.offset = 0

        # internally pre-computed by _Init()
        self._incr = 0

    #========================================
    # Define this if necessary.   Usually called when a game Activates.
    def Reset(self):    pass

    #========================================
    def Copy(self):
        """Return a functionally-independent copy of this updater.
        """
        newobj = type(self)()
        newobj.__dict__.update(self.__dict__)       # shallow copy
        # disconnect
        newobj.target = None
        newobj.axis = None
        return newobj



    #========================================
    def _Init(self):
        """Initialize the MJUpdater internal values.
           Pre-compute any necessary values.
           This should only be called by the axis that owns this updater.
        """
        ax = self.axis
        self._incr = self.incr/100.0 * ax.maxVal  # signed

    #========================================
    def decayFactor(self, deltaT):
        """Return the decay factor for this updater, scaled to deltaT.
           self.decay is seconds to decay to 1% of its value.
           deltaT is the (actual) execution interval since last call.
        """
        if self.decay:
            # --> val * decayFactor^(decay/deltaT) = 0.01*val
            # XXX: rewrite this to not use pow(); only need a rough approx.
            return pow(0.1, deltaT/self.decay)
        else:
            return 1.0

    #========================================
    def CaptureOffset(self):
        """Capture the current axis value into offset"""
        ax = self.axis
        val = ax.currVal
        if ax.OnAxis(val):
            self.offset = val

    #========================================
    # implemented by subclass
    def Update(self): pass

#===========================================================
class MJMouse:
    """A class to return mouse delta values using the default FreePIE mouse.
    """

    def __init__(self, G):
        self.G = G
        self.x_smoother = None
        self.y_smoother = None

    def Reset(self):
        if self.x_smoother: self.x_smoother.Reset()
        if self.y_smoother: self.y_smoother.Reset()

    def getDeltaX(self):
        val = self.G.mouse.deltaX
        if self.x_smoother:
            val = self.x_smoother.Update(val)
        return val
    def getDeltaY(self):
        val = self.G.mouse.deltaY
        if self.y_smoother:
            val = self.y_smoother.Update(val)
        return val

#===========================================================
class MJMouseUpdater(MJUpdater):
    """MJUpdater for mouse movements.
    """
    def __init__(self, mouse=None):
        """Create and return a MJUpdater for mouse movements.
        If mouse is provided, it is used as the mouse device;
        otherwise the default one is used.
        It is ignored if the class object already has a mouse set.
        """
        super(MJMouseUpdater, self).__init__()
        # (these defaults are appropriate for mouse look...)
        self.scale = 5          # joy axis travel per mouse movement
        self.accel = 2          # percent of squared movement to add
        self.maxAccel = 5       # Maximum acceleration factor
        self.decay = None       # seconds to decay to 1% of its value
        if mouse:
            self.mouse = mouse
        else:
            self.mouse = None
        self.first = True       # First call after Reset()

    #========================================
    def Reset(self):
        if self.mouse:
            self.mouse.Reset()
        self.first = True

    #========================================
    def Update(self):
        """Updater according to mouse movement."""
        # Only run if our target has mouseEnabled
        if not self.target.mouseEnabled: return
        ax = self.axis
        val = ax.currVal
        if not ax.OnAxis(val): return

        if self.first:
            # first call after Reset (window-switch) is a wonky delta
            self.first = False
            delta = 0
        else:
            if ax.isHoriz:
                delta = self.mouse.getDeltaX()
            else:
                delta = -self.mouse.getDeltaY()        # inverted

        incr = delta * self.scale
        adelta = abs(delta)
        accel = self.accel/100.0 * adelta
        if accel > self.maxAccel:
            accel = self.maxAccel
        val += incr * (1.0 + accel)
        ax.currVal = val
        ax.decayFactor = self.decayFactor(ax.deltaT)

        ax.dbgIncr('M+', incr, accel, adelta)

    #========================================
    def _Init(self):
        super(MJMouseUpdater, self)._Init()
        if not self.mouse:
            self.mouse = MJMouse(self.G)

#===========================================================
class MJTrackerUpdater(MJUpdater):
    """MJUpdater for head tracker input.
    """
    def __init__(self, tracker=None):
        """Return an MJUpdater that uses headtracker tracker."""
        super(MJTrackerUpdater, self).__init__()
        self.tracker = tracker
        self.scale = 1.0        # scale multiplier at the origin (offset)
        self.accel = 0.5        # percent of squared offset to add
        self.maxAccel = 5       # Maximum acceleration factor
        self.decay = None       # seconds to decay to 1% of its value
        self.offset = 0         # This is set by CaptureOffset()

    #========================================
    def Reset(self):
        if self.tracker:
            self.tracker.Reset()
    #========================================
    def Update(self):
        """Update axis according to head tracking"""
        if not self.target.trackerEnabled: return
        if not self.tracker: return
        ax = self.axis
        if ax.isHoriz:
            val = self.tracker.getX()
        else:
            val = self.tracker.getY()
        if not ax.OnAxis(val): return       # quick abort

        delta = val         # delta here is distance from the origin
        incr = delta * self.scale
        adelta = abs(delta)
        accel = self.accel/100.0 * adelta
        if accel > self.maxAccel:
            accel = self.maxAccel
        val = self.offset + incr * (1.0 + accel)
        ax.currVal = val
        #ax.decayFactor = self.decayFactor(ax.deltaT)

        ax.dbgIncr('T+', incr, accel, adelta)

#===========================================================
class MJKeyUpdater(MJUpdater):
    """MJUpdater for analog-style response to key/button presses.
       Decays back to preset value.
    """
    def __init__(self, key=None):
        """Create a MJKeyUpdater using key"""
        super(MJKeyUpdater, self).__init__()
        self.key = key              # a FreePIE enum Key type

        self.incr = 50              # percent axisMax per second
        self.accel = 2              # percent of key hold time (in ms) to add
        self.maxAccel = 5           # Maximum acceleration factor
        self.multiKeyAccel = False  # accel uses hold-time of any axis keys.
        self.multiTapThreshold = 0.200 # in seconds; 0 to disable
        self.decay = 1.0            # seconds to decay to 1% of its value
        # Double-tap to go directly to axis maxVal:
        self.doubleTapThreshold = 0.100    # in seconds; 0 to disable
        self.doubleTapMaxAccel = False  # True: use max accel instead of max val
        # key decay is used for the first keyUsageTime seconds after 
        # key press/release; thence mouse/other decay is used.
        self.keyUsageTime = 1.000    # in seconds; 0 to disable key decay

        # Internal
        self.keyIsDown = False      # True if controlling key is down.
        self.keyDownT = 0           # time of last key-down event
        self.keyUpT = 0             # time of last key-up event

    #========================================
    def Reset(self):
        self.keyIsDown = False
        self.keyDownT = 0
        self.keyUpT = 0

    #========================================
    def Update(self):
        """Update this axis according to the key state.
           Applies increment with time-based acceleration.
           If double-tapped, go to max.
        """
        if not self.key: return
        isDown = self.G.keyboard.getKeyDown(self.key)
        ax = self.axis
        currT = ax.currT
        if isDown:
            # Key is down
            val = ax.GetArrestedVal()

            # Compute increment based on actual deltaT
            incr = self._incr * ax.deltaT

            if not self.keyIsDown:
                # Key was just depressed
                self.dbgKey("PRESSED")
                if (currT - self.keyUpT) < self.doubleTapThreshold:
                    # It's a double-tap
                    if self.doubleTapMaxAccel:
                        # Go to max accel (as if held for 2 seconds...)
                        self.dbgKey("MAXACCEL")
                        self.keyDownT = currT - 2.0
                    else:
                        # Go to max
                        self.dbgKey("MAXVAL")
                        val = ax.maxVal
                        incr = 0    # skip the incr
                        holdDuration = 0.0
                        self.keyDownT = currT
                elif self.multiKeyAccel and (
                       ax.keyDownCount > 0
                    or (currT - ax.keyUpT) < self.multiTapThreshold):
                    # Another key is (or was recently) down;
                    # accel doesn't reset.
                    if ax.keyDownCount > 0:
                        # continue from the existing axis keyTime
                        self.dbgKey("MULTIKEY[HELD]")
                    else:
                        # new key down, but don't reset the 
                        # previous axis keyDownT
                        self.dbgKey("MULTIKEY[TAP]")
                    # continue from the previous axis.keyDownT
                    self.keyDownT = ax.keyDownT
                else:
                    # "Normal" key press
                    self.keyDownT = currT
                self.keyIsDown = True
                ax.keyDownCount += 1
                ax.keyDownT = self.keyDownT
                self.dbgKey("       -->")       # show updated values
            holdDuration = currT - self.keyDownT
            accel = self.accel * 10.0 * holdDuration  # 10 = /100% * 1000ms
            if accel > self.maxAccel:
                accel = self.maxAccel

            ax.dbgIncr('K+', incr, accel, holdDuration)

            val += incr * (1.0 + accel)
            ax.currVal = val
            ax.decayFactor = 1  # No decay while key is held
        else:
            # Key is up
            if self.keyIsDown:
                # key was just released
                self.keyIsDown = False
                ax.keyDownCount -= 1
                if ax.keyDownCount == 0:
                    self.dbgKey("RELEASE ALL")
                    ax.keyUpT = currT
                else:
                    self.dbgKey("RELEASE SINGLE")
                self.keyUpT = currT
                self.dbgKey("       -->")       # show updated values
            if (currT - self.keyUpT) < self.keyUsageTime:
                # still considered key-controlled; use our decay
                # (as long as no other key is down):
                if ax.keyDownCount == 0:
                    ax.decayFactor = self.decayFactor(ax.deltaT)
#                    self.G.dbg(ax.dbg, "%s: KEYUSAGE decayFactor=%f", 
#                            ax.name, self.decayFactor(ax.deltaT))


    #========================================
    # Debugging...
    def dbgKey(self, msg=None):
        """ Debugging for key events"""
        if not self.G.Debug: return
        ax = self.axis
        if msg is None:
            # output header
            self.G.dbg(ax.dbg+'K', "%-20s %6s(%6s): " +
                            "%6s %6s [%-6s %6s] (%s)",
                "# AXIS & EVENT",
                "currT",
                "deltaT",
                "DownT",
                "UpT",
                "AxDownT",
                "AxUpT",
                "AxKeys")
            return
        self.G.dbg(ax.dbg+'K', "%-20s %6.3f(%6.3f): " +
                        "%6.3f %6.3f [%6.3f %6.3f] (%d)",
            ax.name+' '+msg,
            ax.currT,
            ax.deltaT,
            self.keyDownT,
            self.keyUpT,
            ax.keyDownT,
            ax.keyUpT,
            ax.keyDownCount)

#===========================================================
class MJOneShotUpdater(MJUpdater):
    """MJUpdater for one-shot key/button presses.
    """
    def __init__(self, key=None):
        """Create a MJKeyUpdater using key"""
        super(MJOneShotUpdater, self).__init__()
        self.key = key          # a FreePIE enum Key type

        self.incr = 5           # key press increment in percent of maxVal
        self.decay = None       # seconds to decay to 1% of its value
        self.fixed = None       # fixed value to set (or None if disabled)
                                # (in percentage [-100,100] of maxVal)
        # Internal
        self.keyIsDown = False  # True if controlling key is down.
        self._fixed = None

    #========================================
    def _Init(self):
        super(MJOneShotUpdater, self)._Init()
        if self.fixed is None:
            self._fixed = None
        else:
            self._fixed = self.fixed/100.0 * self.axis.maxVal * self.axis.sign

        # overrule incr to be one-shot and percentage:
        self._incr = self.incr/100.0 * self.axis.maxVal  # signed

    #========================================
    def Reset(self):
        self.keyIsDown = False

    #========================================
    def Update(self):
        """Update this axis according to the key state.
           Applies the one-shot increment.
        """
        if not self.key: return
        isDown = self.G.keyboard.getKeyDown(self.key)
        ax = self.axis
        if isDown:
            # Key is down
            if not self.keyIsDown:
                # Key was just depressed
                val = ax.GetArrestedVal()
                if self.fixed is None:
                    # increment
                    val += self._incr
                    self.G.dbg(ax.dbg, "%7.3f %s: 1+ %7.2f               ",
                        ax.currT, ax.name, self._incr)
                else:
                    # fixed value
                    val = self._fixed
                    self.G.dbg(ax.dbg, "%7.3f %s: F= %7.2f               ",
                        ax.currT, ax.name, self._fixed)
                ax.currVal = val
                self.keyIsDown = True
                # ax.keyDownCount += 1  # NO: One-shots don't count for this
                ax.decayFactor = 1          # no decay
        else:
            # Key is up
            if self.keyIsDown:
                # key was just released
                self.keyIsDown = False

#==============================================================================
class MJAxis(object):
    """A joystick axis or half-axis.
       An axis may be divided into 2 half-axes:
           +ve      axis.sign = 1       # The MASTER half-axis
           -ve      axis.sign = -1
       In this case, axis.pair points to the other half of the pair.
       For full axes: pair=None, and sign=1.
       Each half-axis maintains its own set of updaters that only operate
       on their half-axis. However, the +ve half-axis is the MASTER and
       holds the actual value of the axis.
    """

    def __init__(self, target, vjsetter, vname, dbg='MJ'):
        """Constructor.  Return a MJAxis belonging to the MouseJoy target.
            vjsetter is the (bound) MTarget vjoy setter function to be used.
            vname is the device name of the vJoy axis mapped to this.
            dbg is the debug facility used to debug this axis.
        """
        self.target = target
        self.vjsetter = vjsetter
        self.vname = vname
        self.dbg = dbg
        self.G = target.G

        # Internal values
        self.pair = None            # The other half-axis (None if whole-axis)
        self.master = self          # The MASTER axis (self if whole-axis)
        self.sign = 1               # Positive (1) or negative (-1) half-axis.
        self.maxVal = 0             # maximum joystick axis value (signed)
        self.currT = 0              # current timestamp
        self.deltaT = 0             # current deltaT (step increment in sec)

        # MASTER axis values (shared between both axis pairs)
        # -- see @property getters/setters
        self.__currVal = 0          # current axis value
        self.__decayFactor = 1.0    # this may be changed by Updaters
        self.__keyDownCount = 0     # refcount for MJKeyUpdaters
        self.__keyDownT = 0         # time of last key-down event on the axis
        self.__keyUpT = 0           # time of last key-up event on the axis

        #========================== USER PARAMETERS ==========================
        self.name = self.vname      # Semantic name (defaults to vJoy axis)
        self.isHoriz = False        # True if horizontal (mouse/tracker X-axis)
        self.updaters = []          # list of updaters for this axis

        # If arrest is True for a half-axis, then any value change for that
        # half-axis arrests (zeroes) any value in the other half-axis.
        # (e.g.  any Brake half-axis update instantly zeros the throttle and
        # vice-versa).
        # Only arrest half-axes can have independent decays; otherwise the
        # decay applies to both half-axes.
        self.arrest = False         # disabled by default

        #=====================================================================


    #========================================
    def AddUpdater(self, updater):
        """Add updater to the list of updaters.
        Updaters are processed in the order they are added.
        """
        updater.axis = self
        updater.G = self.G
        updater.target = self.target
        self.updaters.append(updater)

    #========================================
    def Init(self):
        """Initialize all updaters for this axis.
        Must be called after any of the updater's user-settable parameters
        are changed.
        """
        for updater in self.updaters:
            updater._Init()

    #========================================
    # MASTER axis Getters and Setters
    @property
    def currVal(self):
        """Return the current value for the axis."""
        return self.master.__currVal

    @currVal.setter
    def currVal(self, val):
        """Set the current value for the axis."""
        self.master.__currVal = val

    @property
    def decayFactor(self):
        if self.arrest:
            return self.__decayFactor
        else:
            return self.master.__decayFactor
    @decayFactor.setter
    def decayFactor(self, val):
        """Set the decayFactor for the axis.
           If this is an arrest axis, then each half-axis can have its own
           independent decay; otherwise the decay is shared for both halves.)
           """
        if self.arrest:
            self.__decayFactor = val          # independent decays
        else:
            self.master.__decayFactor = val   # shared (MASTER) decay

    # for multiple MJKeyUpdaters on an axis pair:
    @property
    def keyDownCount(self):
        return self.master.__keyDownCount
    @keyDownCount.setter
    def keyDownCount(self, val):
        self.master.__keyDownCount = val
    @property
    def keyUpT(self):
        return self.master.__keyUpT
    @keyUpT.setter
    def keyUpT(self, val):
        self.master.__keyUpT = val
    @property
    def keyDownT(self):
        return self.master.__keyDownT
    @keyDownT.setter
    def keyDownT(self, val):
        self.master.__keyDownT = val

    #========================================
    def OnAxis(self, x):
        """Return True if value x is on our axis (half-axis);
           False otherwise."""
        if not self.pair: return True
        if self.sign < 0:
            return x < 0
        else:
            return x >= 0

    #========================================
    def GetArrestedVal(self):
        """Return the current axis val with any arrest applied to it.
        (The axis' stored currVal is not changed).
        If this is a half-axis with arrest=True, then
        zero is returned if current value is in the other half-axis."""
        if not self.pair:
            # full axis; no arrest
            return self.__currVal
        if self.sign < 0:
            # negative half-axis
            val = self.pair.__currVal
            if self.arrest and val > 0:
                return 0
            else:
                return val
        else:
            # positive half-axis
            val = self.__currVal
            if self.arrest and val < 0:
                return 0
            else:
                return val

    #========================================
    def Reset(self):
        """Set this axis value to 0."""
        ax = self.master
        ax.__currVal = 0
        self.__keyDownCount = 0
        self.__keyDownT = 0
        self.__keyUpT = 0
        for u in self.updaters:
            u.Reset()

    #========================================
    def Update(self):
        """Update this axis by applying all updaters."""
        for u in self.updaters:
            u.Update()

    #========================================
    def Output(self):
        """Apply any decay, check bounds, and output the value."""
        if self.master is not self: return

        val = self.__currVal
        # Apply any decay
        if self.pair and self.arrest and val < 0:
            # value is in independent -ve half-axis; use its decay
            decayf = self.pair.__decayFactor
            name = self.pair.name
        else:
            decayf = self.__decayFactor
            name = self.name
        val *= decayf

        # Bounds checking (NB: positive axis so maxVal > 0)
        if val > self.maxVal:
            val = self.maxVal
        elif val < -self.maxVal:
            val = -self.maxVal

        # Update and output it
        self.__currVal = val
        self.vjsetter(val)

        self.G.dbg(self.dbg, ' '*42 + "* %.5f = %10.2f [%s]",
            decayf, val, name)

    #========================================
    def dbgIncr(self, id_str, incr, accel, aparm):
        """Issue a debug message for an increment update on this axis."""
        self.G.dbg(self.dbg, "%7.3f %s: %s %7.2f * (1+ %.4f [%.4f])",
                self.currT, self.name, id_str, incr, accel, aparm)

#==============================================================================
class MouseJoy(object):
    """A vJoy target for mouse-to-joy conversion."""

    def __init__(self, G, vjoy_index=0):
        """Constructor: return a MouseJoy using vJoy[vjoy_index].
        G is the PIEGlobals object.
        """

        self.G = G
        self.axes = []
        self.mouseEnabled = False
        self.trackerEnabled = False
        try:
            self.vjoy = self.G.vJoy[vjoy_index]
        except Exception as e:
            self.G.printf("Failed to get vJoy[%d]: %s", vjoy_index, str(e))
            self.vjoy = None

        self.currT = None
        # time interval measuring
        self.dT_count = 0
        self.dT_avg = 0.0
        self.dT_min = 9999.0
        self.dT_max = 0.0


    #========================================
    # A set of vjoy setter functions to use by reference
    def vjsetX(self, val):       self.vjoy.x = val
    def vjsetY(self, val):       self.vjoy.y = val
    def vjsetZ(self, val):       self.vjoy.z = val
    def vjsetRX(self, val):      self.vjoy.rx = val
    def vjsetRY(self, val):      self.vjoy.ry = val
    def vjsetRZ(self, val):      self.vjoy.rz = val
    def vjsetSlider(self, val):  self.vjoy.slider = val
    def vjsetDial(self, val):    self.vjoy.dial = val

    def GetVJSetter(self, vname):
        """Return the vJoy setter for axis vname."""
        if   vname == 'X': setter = self.vjsetX
        elif vname == 'Y': setter = self.vjsetY
        elif vname == 'Z': setter = self.vjsetZ
        elif vname == 'RX': setter = self.vjsetRX
        elif vname == 'RY': setter = self.vjsetRY
        elif vname == 'RZ': setter = self.vjsetRZ
        elif vname == 'SLIDER': setter = self.vjsetSlider
        elif vname == 'DIAL': setter = self.vjsetDial
        else:
            setter = None
        return setter

    #========================================
    def CreateAxis(self, vname, dbg='MJ'):
        """Create and return a full axis for this target MouseJoy.
        vname is the vJoy axis name (see above).
        dbg is the debug facility to use on this axis.
        """
        vjsetter = self.GetVJSetter(vname)
        if not vjsetter:
            self.G.printf("MouseJoy.CreateAxis: INVALID vJoy axis: %s", vname)
            return None
        ax = MJAxis(self, vjsetter, vname, dbg)
        ax.sign = 1
        ax.master = ax
        ax.pair = None
        if vname == 'X' or vname == 'RX':
            ax.isHoriz = True
        else:
            ax.isHoriz = False
        ax.maxVal = self.vjoy.axisMax
        self.axes.append(ax)
        return ax

    #========================================
    def CreateAxisPair(self, vname, dbg='MJ'):
        """Create and return a linked -/+ pair of axes for this target.
        vname is the vJoy axis name.
        dbg is the debug facility to use on this axis (a '-' and
        a '+' will be appended respectively).
        Axes will be returned as a pair: (-ve, +ve).
        """
        axm = self.CreateAxis(vname, dbg)
        axp = self.CreateAxis(vname, dbg)
        if not axm or not axp:
            return None
        # link them
        axm.master = axp
        axm.pair = axp
        axm.sign = -1
        axp.pair = axm
        axm.vname += '-'
        axp.vname += '+'
        axm.maxVal *= -1
        return (axm, axp)

    #========================================
    def Init(self):
        """Initialize all internal processing values."""
        for ax in self.axes:
            ax.Init()

    #========================================
    def Reset(self):
        """Reset all values to initial state.
        Should be called when a window/game Activates."""

        # reset time and interval measuring
        self.currT = None
        #self.G.printf("%6s  DeltaT: avg=%.1f  min=%.1f   max=%.1f (ms)",
        #       self.name, self.dT_avg*1000, self.dT_min*1000, self.dT_max*1000)
        self.dT_count = 0
        self.dT_avg = 0.0
        self.dT_min = 9999.0
        self.dT_max = 0.0

        for ax in self.axes:
            ax.Reset()


    #========================================
    def Run(self):
        """Run this MouseJoy."""

        currT = self.G.clock()
        if self.currT is not None:
            deltaT = currT - self.currT
            # Accumulate timing stats 
            self.dT_count += 1
            self.dT_avg += (deltaT - self.dT_avg)/self.dT_count
            if deltaT > self.dT_max: self.dT_max = deltaT
            if deltaT < self.dT_min: self.dT_min = deltaT
            #self.G.printf( "%9.4f      %.6f", currT, deltaT)
        else:
            #deltaT = currT
            deltaT = 0
        self.currT = currT

        for ax in self.axes:
            ax.deltaT = deltaT
            ax.currT = currT
            ax.Update()
        for ax in self.axes:
            ax.Output()



