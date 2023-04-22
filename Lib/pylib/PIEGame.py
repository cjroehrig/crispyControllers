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
