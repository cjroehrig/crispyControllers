# Freepie sim plugins
#   This module creates dummy versions of FreePIE plugins for 
#   (static) testing purposes using native python.
#   NB: They only implement minimal functionality to test existing code.


#==============================================================================
# keyboard
class SimKeyboard:
    def getKeyDown(self,n): return False
    def getKeyUp(self,n): return False
    def getPressed(self,n): return False
    def setKey(self,n,down): return False
    def setKeyDown(self,n): return False
    def setKeyUp(self,n): return False
    def setPressed(self,n): return False
keyboard = SimKeyboard()

#==============================================================================
# mouse
try:
    import win32apiNOPENOPENOPE
except ModuleNotFoundError:
    print("Not implemented - using dummy SimMouse")
    class SimMouse:
        def getButton(self, n): return False
        def getPressed(self, n): return False
        def setButton(self, n, pressed): pass
        def setPressed(self, n): pass
        @property
        def deltaX(self): return 100
        @property
        def deltaY(self): return 100
        @property
        def leftButton(self): return False
        @property
        def middleButton(self): return False
        @property
        def rightButton(self): return False
        @property
        def wheel(self): return 0
        @property
        def wheelDown(self): return False
        @property
        def wheelUp(self): return False
        @property
        def wheelMax(self): return 120

mouse = SimMouse()

#==============================================================================
# joystick
class SimJoystick:
    def __init__(self):
        self.x = 0
        self.y = 0
        self.z = 0
        self.xRotation = 0
        self.yRotation = 0
        self.zRotation = 0
        self.sliders= [0]
        self.pov = [0]
    def setRange(self, low, high): pass
    def getPressed(self,n): return False
    def getDown(self,n): return False
joystick = {
    0:  SimJoystick(),
    "Logitech WingMan Extreme Digital 3D (USB)": SimJoystick(),
    "EDTracker EDTracker2": SimJoystick(),
}

#==============================================================================
# vJoy
try:
    import vjoyNOPENOPENOPE
except ModuleNotFoundError:
    print("Not implemented - using dummy SimvJoy")
    class SimVJoyVersion:
        api = 537
        driver = 537
    class SimvJoy:
        axisMax = 16382
        continuousPoVMax = 35900
        @property
        def version(self): return SimVJoyVersion()

        def setButton(self, button, pressed): pass
        def setPressed(self, button): pass
        def setAnalogPov(self, pov, val): pass
        def setDigitalPov(self, pov, dir): pass
        # properties
        def getslider(self): return 0
        def setslider(self, val): pass
        slider = property(getslider, setslider)
        def getdial(self): return 0
        def setdial(self, val): pass
        dial = property(getdial, setdial)
        def getx(self): return 0
        def setx(self, val): pass
        x = property(getx, setx)
        def gety(self): return 0
        def sety(self, val): pass
        y = property(gety, sety)
        def getz(self): return 0
        def setz(self, val): pass
        z = property(getz, setz)
        def getrx(self): return 0
        def setrx(self, val): pass
        rx = property(getrx, setrx)
        def getry(self): return 0
        def setry(self, val): pass
        ry = property(getry, setry)
        def getrz(self): return 0
        def setrz(self, val): pass
        rz = property(getrz, setrz)

vJoy = [SimvJoy()]

#==============================================================================
# trackIR
class SimTrackIRUpdater:
    def __init__(self):
        self.u = []
    def __iadd__(self,other):
        self.u.append(other)
class SimTrackIR:
    update = SimTrackIRUpdater()
    pitch = 0
    yaw = 0
trackIR = SimTrackIR()

#==============================================================================
# xbox360
class SimXBox360: pass
xbox360 = [SimXBox360()]

#==============================================================================
# midi
class SimMIDI: pass
midi = SimMIDI()

#==============================================================================
# Key class 
class Key:
    D0 = 0
    D1 = 1
    D2 = 2
    D3 = 3
    D4 = 4
    D5 = 5
    D6 = 6
    D7 = 7
    D8 = 8
    D9 = 9
    A = 10
    B = 11
    C = 12
    D = 13
    E = 14
    F = 15
    G = 16
    H = 17
    I = 18
    J = 19
    K = 20
    L = 21
    M = 22
    N = 23
    O = 24
    P = 25
    Q = 26
    R = 27
    S = 28
    T = 29
    U = 30
    V = 31
    W = 32
    X = 33
    Y = 34
    Z = 35
    AbntC1 = 36
    AbntC2 = 37
    Apostrophe = 38
    Applications = 39
    AT = 40
    AX = 41
    Backspace = 42
    Backslash = 43
    Calculator = 44
    CapsLock = 45
    Colon = 46
    Comma = 47
    Convert = 48
    Delete = 49
    DownArrow = 50
    End = 51
    Equals = 52
    Escape = 53
    F1 = 54
    F2 = 55
    F3 = 56
    F4 = 57
    F5 = 58
    F6 = 59
    F7 = 60
    F8 = 61
    F9 = 62
    F10 = 63
    F11 = 64
    F12 = 65
    F13 = 66
    F14 = 67
    F15 = 68
    Grave = 69
    Home = 70
    Insert = 71
    Kana = 72
    Kanji = 73
    LeftBracket = 74
    LeftControl = 75
    LeftArrow = 76
    LeftAlt = 77
    LeftShift = 78
    LeftWindowsKey = 79
    Mail = 80
    MediaSelect = 81
    MediaStop = 82
    Minus = 83
    Mute = 84
    MyComputer = 85
    NextTrack = 86
    NoConvert = 87
    NumberLock = 88
    NumberPad0 = 89
    NumberPad1 = 90
    NumberPad2 = 91
    NumberPad3 = 92
    NumberPad4 = 93
    NumberPad5 = 94
    NumberPad6 = 95
    NumberPad7 = 96
    NumberPad8 = 97
    NumberPad9 = 98
    NumberPadComma = 99
    NumberPadEnter = 100
    NumberPadEquals = 101
    NumberPadMinus = 102
    NumberPadPeriod = 103
    NumberPadPlus = 104
    NumberPadSlash = 105
    NumberPadStar = 106
    Oem102 = 107
    PageDown = 108
    PageUp = 109
    Pause = 110
    Period = 111
    PlayPause = 112
    Power = 113
    PreviousTrack = 114
    RightBracket = 115
    RightControl = 116
    Return = 117
    RightArrow = 118
    RightAlt = 119
    RightShift = 120
    RightWindowsKey = 121
    ScrollLock = 122
    Semicolon = 123
    Slash = 124
    Sleep = 125
    Space = 126
    Stop = 127
    PrintScreen = 128
    Tab = 129
    Underline = 130
    Unlabeled = 131
    UpArrow = 132
    VolumeDown = 133
    VolumeUp = 134
    Wake = 135
    WebBack = 136
    WebFavorites = 137
    WebForward = 138
    WebHome = 139
    WebRefresh = 140
    WebSearch = 141
    WebStop = 142
    Yen = 143
    Unknown = 144

#==============================================================================
# window
#  NB: this needs Windows Python with PIP modules: pywin32 and psutil
try:
    import sys
    if sys.version_info[0] > 2:
        import builtins
        if 'sim_DUMMYWINDOW' in dir(builtins) and builtins.sim_DUMMYWINDOW: raise ModuleNotFoundError()


    import win32gui
    import win32process
    import psutil
    class SimWindow:
        @property
        def getActive(self):
            handle = win32gui.GetForegroundWindow()
            tid, pid = win32process.GetWindowThreadProcessId(handle)
            process = psutil.Process(pid)
            pname = process.name()
            if pname.endswith(".exe"):
                pname = pname[:-4]
            return pname
except ModuleNotFoundError:
    print("No pywin32 found - using dummy SimWindow")
    class SimWindow:
        @property
        def getActive(self): return "JoystickTest"

window = SimWindow()

#==============================================================================
# diagnostics
class SimDiagnostics:
    def debug(self, fmt, *args):
        print(fmt.format(*args))
diagnostics = SimDiagnostics()

#==============================================================================
# filters
class SimFilters:
    def delta(val,key): return 0
filters = SimFilters()

#==============================================================================
# system
class SimSystem:
    threadExecutionInterval = 1
    #def setThreadTiming(x): pass
system = SimSystem()


#==============================================================================
# XOutput
class SimXOutput: pass
xoutput = [SimXOutput(), SimXOutput(), SimXOutput(), SimXOutput()]
