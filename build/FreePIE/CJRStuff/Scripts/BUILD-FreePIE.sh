#!/bin/bash
##########################################################################
# Build FreePIE
#

[ -d CJRStuff ] || ( echo "Must be in build/FreePIE root dir"; exit 1 )

# build:
./FreePIE/BuildTools/build_console.bat

# mv Console into Output
mv FreePIE/OutputTemp/FreePIE.Console.exe FreePIE/Output
