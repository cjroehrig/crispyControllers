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
        'LMB'           : 0,
        'RMB'           : 1,
        'MMB'           : 2,
        'WHEELUP'       : 3,
        'WHEELDOWN'     : 4,
    }


    def __new__(cls, G, button=None, *args, **kwargs):
        """Class factory.  Returns the appropriate button object
        based on the type/class of button (and any optional args).
        (NB: __init__ will get called after this returns with
        the same args:  G, button, *args, **kwargs)
        """
        if not button:
            # non-functional superclass prototype
            return super(Button, cls).__new__(cls)
        elif type(button) == G.Key:
            # Key
            return super(Button, cls).__new__(KeyButton)
        elif isinstance(button, str):
            if button in cls.MouseButtonDict:
                # Mouse
                return super(Button, cls).__new__(MouseButton)

        G.printf("Unknown Button: " + str(button))
        return None


    def __init__(self, G, button=None, *args, **kwargs):
        self.G = G
        self.button = button
        # Handle modifiers:
        #  XXX: define args/kwargs/syntax for modifiers that MUST be DOWN and
        # modifiers that MUST be UP
        # NB: Modifiers can be any button...
        self.modifiers = []

    def chkModifiers(self):
        """Return True if the state of the button modifiers are consistent
           with this instance's definitions."""
        # Handle modifiers:
        # XXX: kludge for now: just set to false if any are down
        if (self.G.keyboard.getKeyDown(self.G.Key.LeftControl) or
            self.G.keyboard.getKeyDown(self.G.Key.LeftAlt) or
            self.G.keyboard.getKeyDown(self.G.Key.LeftShift) ):
            return False

        return True


    # To be overridden
    def isDown(self):  return False
    def wasDown(self):  return False

#===========================================================
# Keyboard button using default FreePIE keyboard
class KeyButton(Button):

    def isDown(self):
        """Return true if we are pressed"""
        isDown = self.G.keyboard.getKeyDown(self.button)
        isDown = isDown and self.chkModifiers()
        return isDown

#===========================================================
# Mouse button using default FreePIE mouse
# See FreePIE.Core.Plugins/MousePlugin.cs for details
class MouseButton(Button):
    def __init__(self, G, button, *args, **kwargs):
    #def __init__(self, G, button):
        super(MouseButton, self).__init__(G, button, *args, **kwargs)
        # replace button with its FreePIE mouse button ID
        if button in self.MouseButtonDict:
            self.button = self.MouseButtonDict[button]
        else:
            self.button = None # error

    def isDown(self):
        if self.button < 3:
            isDown = self.G.mouse.getPressed(self.button)
        elif self.button == 3:
            isDown = (self.G.mouse.wheel > 0)
        elif self.button == 4:
            isDown = (self.G.mouse.wheel < 0)
        else:
            isDown = False

        isDown = isDown and self.chkModifiers()
        return isDown

