#!/bin/bash
##########################################################################
# BUILD-plugins: build the extra FreePIE plugins
# NB: some of these commands need Administrator access.

[ -d CJRStuff ] || echo "Must be in build/FreePIE root dir"; exit 1

##########################################################################
# XOutputPlugin:

# build -- nb: this needs to find FreePIE in Program Files (x86)
cd XOutputPlugin
../CJRBuildTools/build_xoutputplugin.bat

mv XOutputPlugin/obj/Release/XOutputPlugin.dll  "$INSTALL_DIR/plugins/"

