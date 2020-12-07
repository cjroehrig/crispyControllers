# Smoother
"""Smoother - a set of classes for smoothing.

    These only work if Update() is called only once per sample frame.
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

import math
#==============================================================================
class Smoother(object):
    """An superclass for smoothing a value.  Passthrough."""
    def __init__(self, G):
        """Constructor. Return a Smoother."""
        self.G = G
        self.name = "SM"

    #========================================
    # Override if necessary
    def Reset(self): pass
    #========================================
    def Update(self, val):
        """Return the smoothed version of val. Passthrough"""
        return val


#===========================================================
class SimpleSmoother(Smoother):
    """A simple 1-sample average smoother."""

    def __init__(self, G):
        super(SimpleSmoother, self).__init__(G)
        self.prevVal = None

    def Reset(self):
        self.prevVal = 0

    def Update(self, val):
        if self.prevVal is None:
            self.prevVal = val
        newval = (val + self.prevVal) / 2.0
        self.prevVal = newval
        self.G.dbg('SM', "%-16s %10.2f %10.2f %10.2f",
            self.name,
            prevVal, val, newval)
        return newval

#===========================================================
class MovingAvgSmoother(Smoother):
    """A Smoother using an n-sample moving average.
    Probably the most effective  based on playing with the interactive
    demo at the One Euro Filter site:
    http://cristal.univ-lille.fr/~casiez/1euro/
    """

    def __init__(self, G, N):
        """Return an N-sample MovingAvgSmoother."""
        super(MovingAvgSmoother, self).__init__(G)
        self.N = N
        self.buf = [0.0 for n in range(N)]
        self.currIdx = 0
        self.currAvg = 0.0

    def Reset(self):
        for i in range(self.N):
            self.buf[i] = 0.0
        self.currIdx = 0
        self.currAvg = 0.0


    def Update(self, val):
        i = self.currIdx
        oldval = self.buf[i]
        self.buf[i] = val
        self.currIdx = (self.currIdx + 1) % self.N
        oldAvg = self.currAvg
        self.currAvg = oldAvg + float(val - oldval)/self.N

        self.G.dbg('SM', "%-16s %10.2f %10.2f [%d/%d] %10.2f",
            self.name,
            oldAvg, val, i, self.N, self.currAvg)
        return self.currAvg

#===========================================================
class AccelSmoother(Smoother):
    """A Smoother that limits the second derivative (wrt time).
    XXX: Has convergence/ringing issues with fast movements.
    """

    def __init__(self, G):
        super(AccelSmoother, self).__init__(G)
        self.prevVal = None
        self.prevT = None
        self.prev_dxdt = 0.0
        # USER parms:
        self.maxAccel = 0.1

    def Reset(self):
        self.prevVal = None
        self.prevT = None
        self.prev_dxdt = 0.0

    def Update(self, val):
        currT = self.G.clock()
        if self.prevT is None:
            self.prevT = currT
            self.prevVal = val
            return val
        deltaT = currT - self.prevT

        dxdt = (val - self.prevVal)/deltaT
        d2xdt2 = (dxdt - self.prev_dxdt)/deltaT
        if abs(d2xdt2) > self.maxAccel:
            d2xdt2 = math.copysign(self.maxAccel, d2xdt2)
            dxdt = self.prev_dxdt + d2xdt2*deltaT
            newval = self.prevVal + dxdt * deltaT
            self.G.dbg('SM', "%-16s %10.2f %10.2f %10.2f",
                self.name + "[CLAMP]",
                newval, dxdt, d2xdt2)
        else:
            newval = val
            self.G.dbg('SM', "%-16s %10.2f %10.2f %10.2f",
                self.name,
                newval, dxdt, d2xdt2)

        self.prevVal = newval
        self.prev_dxdt = dxdt
        self.prevT = currT
        return newval
