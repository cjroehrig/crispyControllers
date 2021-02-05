# EDTracker
"""
    EDTracker: EDTracker head tracker
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

#==============================================================================
from crispy.Analog import AnalogXYZ

class EDTracker(AnalogXYZ):
    def __init__(self, G, comPort=None, axisMax=1000):
        """Return an EDTracker device.
        If comPort is specified, use it; otherwise auto-detect it.
        XXX: only works if there is only one existing COM port.
        """
        super(EDTracker, self).__init__(G)
        self.axisMax = axisMax
        try:
            self.edjoy = self.G.joystick["EDTracker EDTracker2"]
            if not self.edjoy: raise Exception("not found")
            self.edjoy.setRange(-axisMax, axisMax)
        except Exception as e:
            self.G.printf("EDTracker: %s", str(e))
            self.edjoy = None
            self.comPort = None

        if self.edjoy:
            if comPort is not None:
                self.comPort = comPort
            else:
                self.comPort = self._findPortName()
            self.G.printf("Using EDTracker on %s", self.comPort )

    #========================================
    def _findPortName(self):
        """Find the serial port for our device."""
        import sys
        if sys.implementation.name != 'ironpython': return None
        from System.IO.Ports import SerialPort
        for port in SerialPort.GetPortNames():
            self.G.dbg('ED', "EDTracker._findPortName(): found port: %s", port)
            # XXX: HACK: assume it is the ONLY serial port.  True for me :P
            return port
            ## To really check, send an 'I' command and get a multi-line
            ## info response that starts with 'I\tEDTracker'. Timeouts, etc.
            ## See the EDTracker arduino code.
        return None


    #========================================
    def Reset(self):
        super(EDTracker, self).Reset()

    #========================================
    # Get current Hardware values
    def _getHWX(self): return self.edjoy.x if self.edjoy else 0
    def _getHWY(self): return self.edjoy.y if self.edjoy else 0
    def _getHWZ(self): return self.edjoy.z if self.edjoy else 0

    #========================================
    def Center(self):
        """Center (zero) EDTracker head position."""
        if not self.comPort:
            self.G.printf("EDTracker: can't Center(); " +
                "no comPort defined")
            return
        try:
            # XXX: this doesn't raise an exception if EDTracker
            # becomes disconnected...
            from System.IO.Ports import SerialPort
            serial = SerialPort(self.comPort, 57600)
            serial.Open()
            serial.Write('R')
            serial.Close()
            self.G.dbg('ED', "EDTracker.Center() succeeded")
        except Exception as e:
            self.G.printf("EDTracker.Center() failed: %s", str(e))
