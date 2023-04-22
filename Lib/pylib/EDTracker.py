# EDTracker
"""
    EDTracker: EDTracker head tracker
"""

#===============================================================================
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
