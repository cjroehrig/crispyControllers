# Button
"""Button  - superclass and some common button classes
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

#===========================================================
# The superclass
class Button(object):

    # Names for buttons
    MouseButtonDict = {
        'LMB'           : 1,
        'MMB'           : 2,
        'RMB'           : 3,
        'WHEELUP'       : 4,
        'WHEELDOWN'     : 5,
    }


    def __new__(cls, G, button, arg=None):
        """Class factory.  Returns the appropriate button object
        based on the type/class of button (and any optional arg).
        (NB: __init__ will get called after this returns.)
        """
        if not button:
            return super(Button, cls).__new__(cls)

        # Key
        elif type(button) == G.Key:
            return super(Button, cls).__new__(KeyButton)

        elif isinstance(button, str):
            # Mouse
            if button in cls.MouseButtonDict:
                return super(Button, cls).__new__(MouseButton)

        G.printf("Unknown Button: " + button)
        return None


    def __init__(self, G, button=None):
        self.G = G
        self.button = button

    # To be overridden
    def isDown(self):  return False
    def wasDown(self):  return False

#===========================================================
# Keyboard button using default FreePIE keyboard
class KeyButton(Button):
    def isDown(self):
        """Return true if we are pressed"""
        return self.G.keyboard.getKeyDown(self.button)

#===========================================================
# Mouse button using default FreePIE mouse
class MouseButton(Button):
    def __init__(self, G, button):
        super(MouseButton, self).__init__(G, button)
        # replace button with its FreePIE mouse button ID
        if button in self.MouseButtonDict:
            button = self.MouseButtonDict[button]
        else:
            self.button = None # error

    def isDown(self):
        """Return true if we are pressed"""
        return self.G.mouse.getButton(self.button)

