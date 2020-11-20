#!/bin/bash
# - create necessary windows FreePIE symlinks from the App dir to
# the crispyControllers libraries.

DO_BUILD=true				# also do the app in the build/ dir

if [ -n "$1" ]; then
	FPDIR="$1"
else
	FPDIR="/cygdrive/c/Program Files (x86)/FreePIE"
fi
WFPDIR="$(cygpath -w "$FPDIR")"
WDOCDIR="$USERPROFILE\Documents\crispyControllers"
DOCDIR="$(cygpath "$WDOCDIR")"

BFPDIR="build/FreePIE/FreePIE/Output"
WBFPDIR="$(cygpath -w "$BFPDIR")"

# Check for Administrator
net session > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Must be Administrator";
	exit 1
fi

# symlinks from the App dir...
$EXEC rm -f "$FPDIR/pylib/Games"
$EXEC rm -f "$FPDIR/pylib/crispy"
$EXEC cmd /c mklink /d "$WFPDIR\\pylib\\crispy" "$WDOCDIR\\Lib\\pylib"
$EXEC cmd /c mklink /d "$WFPDIR\\pylib\\Games" "$WDOCDIR\\Games"

# Create crispy symlink in crispyController dir for simulator:
cd "$DOCDIR"
$EXEC rm -f crispy
$EXEC cmd /c mklink /d "crispy" "Lib\\pylib"



# symlinks from the Build dir...
if [ -n "$DO_BUILD" ]; then
	$EXEC rm -f "$BFPDIR/pylib/Games"
	$EXEC rm -f "$BFPDIR/pylib/crispy"
	$EXEC cmd /c mklink /d "$WBFPDIR\\pylib\\crispy" "$WDOCDIR\\Lib\\pylib"
	$EXEC cmd /c mklink /d "$WBFPDIR\\pylib\\Games" "$WDOCDIR\\Games"
fi


