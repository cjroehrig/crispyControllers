# Analog
"""Analog - a collection of superclasses for analog controller input."""

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
