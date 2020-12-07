#==============================================================================
# crispyController FreePIE main
#   
#   This initializes all games and switches processing based on the
#   currently active game/exe.
#
#   Requirements:
#   - ./Lib/pylib symlinked from $PF86/FreePIE/pylib/crispy (see ./INSTALL)
#
# NB: FreePIE executes this whole file repeatedly every threadExecutionInterval.
# DO NOT put initialization stuff outside of the "if starting:" block!
# (Actually, it sleep(threadExecutionInterval) after each execution, so 
# the execution frequency is actually slower than threadExecutionInterval).
# 
#==============================================================================
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

#==============================================================================
# DEBUGGING: Uncomment this section to allow debugging (even via native python)
Debug = True
import sys
if sys.implementation.name != 'ironpython':
    print("Loading simulator plugins")
    from crispy.sim_plugins import *
    starting = True
else:
    from System import Console   # .NET for printf

#==============================================================================
#=================  START OF starting: BLOCK  =================================
if starting:
    import sys
    import time
    #================================================
    class PIEGlobals:
        """Encapsulate all globals for use in modules.
        FreePIE has a bunch of special globals which are accessible
        only in this main file and don't appear in globals().
        For use in modules, we store and pass them in the G object.
        """
        #-------------------------
        # Standard FreePIE plugins
        Key             = Key
        diagnostics     = diagnostics
        filters         = filters
        joystick        = joystick
        keyboard        = keyboard
        midi            = midi
        mouse           = mouse
        system          = system
        trackIR         = trackIR
        vJoy            = vJoy
        window          = window
        xbox360         = xbox360
        #-------------------------
        # Additional custom plugins
        #xoutput         = xoutput

        #-------------------------
        # Timing
        if sys.implementation.name == 'ironpython':
            def clock(self):
                return time.clock()
        else:
            def clock(self):
                return time.perf_counter()
        #-------------------------
        # Output
        prt             = diagnostics.debug
        def printf(self, fmt, *args):
            self.prt(fmt % args)        # NB: includes newline
        # XXX: test the following; only for python 3+
        # XXX: need to rewrite all printf calls to add \n
        #if sys.implementation.name == 'ironpython':
        #    def printf(self, fmt, *args):
        #        """C-style printf"""
        #        Console.Write(fmt % args)
        #else:
        #    def printf(self, fmt, *args):
        #        """C-style printf"""
        #        # NB: can't even write print(..., end='') in python 2.7
        #        # .. and can't 'from __future__' in FreePIE (it has
        #        # already injected script code before it reads this file).
        #        sys.stdout.write(fmt % args)
        #-------------------------
        # Debugging
        dbg_facilities  = []
        def dbgon(self, facility):
            """Turn on the given debugging facility."""
            if facility not in self.dbg_facilities:
                self.dbg_facilities.append(facility)
        def dbgoff(self, facility):
            """Turn off the given debugging facility."""
            if facility in self.dbg_facilities:
                self.dbg_facilities.remove(facility)
        def dbg(self, facility, fmt, *args):
            """Print this debug message if facility is turned on"""
            if not self.Debug: return        # fast rejection
            if facility in self.dbg_facilities:
                self.printf('>> '+fmt, *args)
        _printr_recursed = None
        def _printr_objs(self, obj, _indent):
            """ Internal recursion checker and object printer for printr()"""
            if _indent > 40:
                self.printf("ABORTING: RECURSION TOO DEEP")
                return
            if isinstance(obj, list) or isinstance(obj, set):
                for i in obj: self._printr_objs(i, _indent)
            elif isinstance(obj, dict):
                for k in obj: self._printr_objs(obj[k], _indent)
            elif '__dict__' in dir(obj):      # object
                self.printr(obj, _indent)
            else:  # scalar
                pass
        def printr(self, obj, _indent=0):
            """Recursively dump/print obj."""
            if _indent == 0:     # first run
                self._printr_recursed = [self]  # exclude PIEGlobals
            if '__dict__' in dir(obj):      # object
                if obj not in self._printr_recursed:
                    self._printr_recursed.append(obj)
                    self.printf(' '*_indent + str(obj))
                    for k,v in obj.__dict__.items():
                        self.printf(' '*(_indent+2) + k + ": " + str(v))
                        self._printr_objs(v, _indent+4)
            else:
                self.printf(' '*_indent + str(obj))
                self._printr_objs(v, _indent+2)
            if _indent == 0:
                self._printr_recursed = None

    #================================================
    def TimingTester(G):
        """Self-contained function to produce timing results."""
        if not hasattr(TimingTester, "G"):
            # initialize our static variables, print header
            TimingTester.G = G
            TimingTester.startT = G.clock()
            TimingTester.currT = TimingTester.startT
            TimingTester.freePIEdeltaT = 0
            G.printf( "Measuring actual ExecutionInterval deltaT...")
            G.printf( "%20s %10s (%10s)",
                    "ExecutionIntervals", "actualTime", "deltaT")
            return

        # accumulate timing stats
        TimingTester.prevT = TimingTester.currT
        TimingTester.currT = G.clock()
        deltaT = TimingTester.currT - TimingTester.prevT
        totT = TimingTester.currT - TimingTester.startT
        TimingTester.freePIEdeltaT += G.system.threadExecutionInterval

        # produce output every 1000ms:
        if totT >= 1.000:
            G.printf( "%20d %10.4f (%10.4f)",
                TimingTester.freePIEdeltaT, totT, deltaT)
                    #float(totT.total_seconds()),
                    #float(deltaT.total_seconds()))
            TimingTester.freePIEdeltaT = 0
            TimingTester.startT = G.clock()
            TimingTester.currT = TimingTester.startT

    #================================================
    # Create the PIEGlobals object
    if not 'Debug' in globals(): Debug = False      # make sure Debug exists
    G = PIEGlobals()      # the PIEGlobals object
    G.Debug = Debug

    #================================================
    # Turn on any Debugging facilities
    G.dbgon('SW')           # GameSwitcher
    #G.dbgon('MJSX')           # MouseJoy Steer X
    #G.dbgon('MJSY')           # MouseJoy Steer X
    #G.dbgon('MJLX')           # MouseJoy Look Y
    #G.dbgon('MJLY')           # MouseJoy Look Y
    #G.dbgon('MJLXS')          # MouseJoy Look X Smoothing
    #G.dbgon('MJLYS')          # MouseJoy Look Y Smoothing
    #G.dbgon('MJSXK')          # MouseJoy Steer X Key presses
    #G.dbgon('MJSYK')          # MouseJoy Steer Y Key presses
    #G.dbgon('SM')           # Smoothing
    G.dbgon('ED')           # EDTracker

    #================================================
    # Loop interval (in milliseconds)  -- default is 1 ms
    system.threadExecutionInterval = 1

    #================================================
    # Import Games and initialize the Game Switcher
    from crispy.GameSwitcher import GameSwitcher

    # GAMES
    import Games.EliteDangerous
    import Games.EuroTrucks2
    import Games.AmerTrucks
    import Games.Kerbal
    import Games.JoystickTest

    switcher = GameSwitcher(G)
    G.printf("Init completed; running...")

    #===========================================
    # Simulator loop
    if Debug and sys.implementation.name != 'ironpython':
        starting = False
        while True:
            switcher.Run()
            #time.sleep(G.system.threadExecutionInterval)
            time.sleep(0.2)         # 5Hz for debugging

#=================  END OF starting: BLOCK  ===================================


#===========================================
# freepie:  uncomment to run just a few iterations
#count = 0
#if count > 10: sys.exit()
#count += 1

#TimingTester(G)            # uncomment to produce timing output
switcher.Run()
