# GameSwitcher
"""GameSwitcher - switch a PIEGame to the active game."""


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

