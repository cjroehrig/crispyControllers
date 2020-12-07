# GameSwitcher
"""GameSwitcher - switch a PIEGame to the active game."""


#===============================================================================
__copyright__ = """
Copyright 2020 Chris Roehrig <croehrig@crispart.com>

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"""

#===============================================================================

import sys
import re
from crispy.PIEGame import PIEGameClass

class GameSwitcher:

    def __init__(self, G):
        """Record all loaded Games modules in G.Games."""
        self.G = G              # the PIEGlobal object
        self.Games = []         # list of loaded PIEGame objects
        self.currWin = None     # current active window's process name
        self.currGame = None    # current active PIEGame 

        # Find all Game modules and instantiate their objects
        for m in sys.modules.keys():
            # only match top-level Games.XXXX modules
            if re.match("^Games\.[^.]+$", m):
                mod = sys.modules[m]
                if (hasattr(mod, "PIEGame") and
                    issubclass(mod.PIEGame, PIEGameClass)):
                    # instantiate it
                    g = mod.PIEGame(G)
                    g._name = mod.__name__[6:] # remove leading Games.
                    self.Games.append(g)
                    G.dbg('SW',"Loaded Game Module %s (process:%s%s)",
                        g._name, g.ProcessName,
                        "<BG>" if g.RunInBackground else "" )
                    #G.printr(dir(mod))   # uncomment to see module
                else:
                    G.printf("Warning: Module %s has no class PIEGame",
                        mod.__name__)
                    continue
        # Initialize all Game modules that run in the background
        for g in self.Games:
            if g.RunInBackground:
                G.dbg('SW',"Initializing Game: " + g._name)
                g.Init()
                g.Inited = True

    def check_switch(self):
        """Run the current game, switching games if necessary."""
        w = self.G.window.getActive
        if w != self.currWin:
            # active window has changed
            G = self.G
            self.currWin = w

            # Suspend current game 
            g = self.currGame
            if g:
                G.dbg('SW',"Suspending Game: " + g._name)
                g.IsForeground = False
                g.Suspend()
            self.currGame = None

            # check if new window is one of our games
            for g in self.Games:
                if g.ProcessName == w:
                    self.currGame = g
                    # Initialize the game if it hasn't been yet:
                    if not g.Inited:
                        G.dbg('SW',"Initializing Game: " + g._name)
                        g.Init()
                        g.Inited = True
                    # Activate the game
                    G.dbg('SW',"Activating Game: " + g._name)
                    g.IsForeground = True
                    g.Activate()

    def Run(self):
        """Check for a window switch and run all the games."""
        self.check_switch()
        for g in self.Games:
            if g.IsForeground or g.RunInBackground:
                g.Run()

