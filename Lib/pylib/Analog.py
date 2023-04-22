# Analog
"""Analog - a collection of superclasses for analog controller input."""

#===============================================================================
#===========================================================
class AnalogXY(object):
    """AnalogXY - a superclass for a 2D X/Y analog controller input.
        Supports smoothers which need to be manually assigned after creation.
        (See Smoother.py)
        Subclasses should override _getHWDeltaX and Y.
    """
    def __init__(self, G):
        self.G = G
        self.x_smoother = None
        self.y_smoother = None

    def Reset(self):
        if self.x_smoother: self.x_smoother.Reset()
        if self.y_smoother: self.y_smoother.Reset()

    def getDeltaX(self):
        val = self._getHWDeltaX()
        if self.x_smoother:
            val = self.x_smoother.Update(val)
        return val

    def getDeltaY(self):
        val = self._getHWDeltaY()
        if self.y_smoother:
            val = self.y_smoother.Update(val)
        return val

    # These need to be overridden by subclasses:
    def _getHWDeltaX(self): return 0
    def _getHWDeltaY(self): return 0

#===========================================================
class AnalogXYZ(object):
    """AnalogXYZ - a superclass for a 3D X/Y/Z analog controller input.
        Supports smoothers which need to be manually assigned after creation.
        (See Smoother.py)
        Subclasses should override _getHWDeltaX, Y, and Z
    """
    def __init__(self, G):
        self.G = G
        self.x_smoother = None
        self.y_smoother = None
        self.z_smoother = None

    def Reset(self):
        if self.x_smoother: self.x_smoother.Reset()
        if self.y_smoother: self.y_smoother.Reset()
        if self.z_smoother: self.z_smoother.Reset()

    def getX(self):
        val = self._getHWX()
        if self.x_smoother:
            val = self.x_smoother.Update(val)
        return val

    def getY(self):
        val = self._getHWY()
        if self.y_smoother:
            val = self.y_smoother.Update(val)
        return val

    def getZ(self):
        val = self._getHWZ()
        if self.z_smoother:
            val = self.z_smoother.Update(val)
        return val

    # These need to be overridden by subclasses:
    def _getHWX(self): return 0
    def _getHWY(self): return 0
    def _getHWZ(self): return 0
