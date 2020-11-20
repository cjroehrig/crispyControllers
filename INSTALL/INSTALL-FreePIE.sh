#!/bin/bash
#========================================================================
# INSTALL_FreePIE:  Run in Administrator Terminal
EXEC=

INSTALL_DIR="/cygdrive/c/Program Files (x86)/FreePIE"

# Windows versions of paths
WPYLIB="$(cygpath -w "$INSTALL_DIR/pylib")"
WDOCDIR="$USERPROFILE\Documents\crispyControllers"

# Check for Administrator
net session > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Must be Administrator";
	exit 1
fi

# Make sure we are in our directory
cd "$(dirname ${BASH_SOURCE[0]})"

echo "Installing to $INSTALL_DIR"
$EXEC rm -rf "$INSTALL_DIR"
$EXEC cp -a FreePIE "$INSTALL_DIR"

# Create the symlinks
./mklinks.sh "$INSTALL_DIR"
