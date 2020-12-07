# PIEGame
"""PIEGame - abstract superclass for a FreePie Game module

   A FreePIE Game module is a top-level python module of the form:
        Games.XXXXX
   and must contain a subclass definition called PIEGame:
        class PIEGame(PIEGameClass):
   which must override the following:
        ProcessName     - the window process name to detect this game.
        Run()           - Called every threadExecutionInterval
    and may also override:
        RunInBackground - To Run() even when window is not foreground.
        Init()          - Called once to initialize the game.
                        - NB: this is only called the first time the window
                          is actually active.
        Activate()      - Called when the window becomes active (foreground).
        Suspend()       - Called when the window loses foreground.
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

class PIEGameClass(object):
    ProcessName = "PIEGameClass_SUPERCLASS"
    RunInBackground = False         # Set to True to run in background.
    def __init__(self, G):
        self.G = G                  # The PIEGlobals object
        self.IsForeground = False   # True if window is foregound
        self.Inited = False         # True if Init() has been called
        self._name = None           # automatically set to the module name

    # For subclasses to override:
    def Run(self): pass
    def Init(self): pass
    def Activate(self): pass
    def Suspend(self): pass
