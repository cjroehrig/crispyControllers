# EDTracker
"""
    EDTracker: EDTracker head tracker
"""

#==============================================================================
class EDTracker:
    def __init__(self, G, comPort=None, axisMax=1000):
        """Return an EDTracker device.
        If comPort is specified, use it; otherwise auto-detect it.
        XXX: only works if there is only one existing COM port.
        """
        self.G = G
        self.axisMax = axisMax
        self.x_smoother = None
        self.y_smoother = None
        self.z_smoother = None
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
        if self.x_smoother: self.x_smoother.Reset()
        if self.y_smoother: self.y_smoother.Reset()
        if self.z_smoother: self.z_smoother.Reset()

    #========================================
    # Get current values
    def getX(self):
        if not self.edjoy: return 0
        val = self.edjoy.x
        if self.x_smoother:
            val = self.x_smoother.Update(val)
        return val
    def getY(self):
        if not self.edjoy: return 0
        val = self.edjoy.y
        if self.y_smoother:
            val = self.y_smoother.Update(val)
        return val
    def getZ(self):
        if not self.edjoy: return 0
        val = self.edjoy.z
        if self.z_smoother:
            val = self.z_smoother.Update(val)
        return val
    #========================================
    def Center(self):
        """Center (zero) EDTracker head position."""
        if not self.comPort:
            self.G.printf("EDTracker: can't Center(); " +
                "no comPort defined")
            return
        try:
            from System.IO.Ports import SerialPort
            serial = SerialPort(self.comPort, 57600)
            serial.Open()
            serial.Write('R')
            serial.Close()
            self.G.dbg('ED', "EDTracker.Center() succeeded")
        except Exception as e:
            self.G.printf("EDTracker.Center() failed: %s", str(e))
