#!/bin/bash

# Windows-style paths are prefaced with 'W'...
FPDIR="/cygdrive/c/Program Files (x86)/FreePIE"
WFPDIR="$(cygpath -w "$FPDIR")"

WDOCDIR="$USERPROFILE\\Documents\\crispyControllers"
DOCDIR="$(cygpath "$WDOCDIR")"

BFPDIR="build/FreePIE/FreePIE/Output"
WBFPDIR="$(cygpath -w "$BFPDIR")"

#==============================================================================
log(){ printf "$@"; }
vlog(){ if [ $VERBOSE -ge 1 ]; then printf "$@"; fi ; }
vvlog(){ if [ $VERBOSE -ge 2 ]; then printf "$@"; fi ; }
#==============================================================================
# USAGE
usage(){
echo >&2 "\
Usage: $PROG [OPTIONS] [pfdir]
Create necessary Windows symlinks for FreePIE to locate the python files.

Options:
    -n              Don't do anything; instead show what would be done.
    -v              Increase verbosity.
    -h              Print usage help and exit.
    -B              Replace the link in the local build directory.
    -F              Replace the link in the FreePIE install directory.
    -S              Replace the link for the simulator in the doc directory

If [pfdir] is provided (as a cygwin/unix-style path), it is used as
the FreePIE app install directory; otherwise the default install directory
is used.

At least one of -B, -F or -S must be provided to do anything.


Default FreePIE install directory:
        $FPDIR
crispyControllers document directory:
        $DOCDIR

"
}


#==============================================================================
# MAIN

PROG="`basename $0`"
VERBOSE=0
EXEC=""

DO_APP=false
DO_BUILD=false
DO_SIM=false

OPTIND=1
while getopts BFSnv\?h arg; do
	case "$arg" in
	B) DO_BUILD=true ;;
	F) DO_APP=true ;;
	S) DO_SIM=true ;;
	n) EXEC="echo" ;;
	v) let VERBOSE+=1 ;;
	[?h]) usage; exit 2 ;;
	*) echo >&2 "invalid option: $arg"; usage; exit 2 ;;
	esac
done
# skip option arguments:
shift `expr $OPTIND - 1`

# Parse rest of args
case $# in
0) : ;;
1)	FPDIR="$1" ;;
*) echo >&2 "$PROG: extra argument(s)"; usage; exit 2 ;;
esac


if ! $DO_APP && ! $DO_BUILD && ! $DO_SIM; then
	log "Nothing to do.\n"
	exit 2
fi


# Check for Administrator
net session > /dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "Must be Administrator";
	exit 1
fi


# App dir...
if $DO_APP; then
	vlog "Creating symlinks in $FPDIR...\n"
	$EXEC rm -f "$FPDIR/pylib/Games"
	$EXEC rm -f "$FPDIR/pylib/crispy"
	$EXEC cmd /c mklink /d "$WFPDIR\\pylib\\crispy" "$WDOCDIR\\Lib\\pylib"
	$EXEC cmd /c mklink /d "$WFPDIR\\pylib\\Games" "$WDOCDIR\\Games"
fi

# DOCDIR for simulator:
if $DO_SIM; then
	vlog "Creating symlinks in $DOCDIR...\n"
	cd "$DOCDIR"
	$EXEC rm -f crispy
	$EXEC cmd /c mklink /d "crispy" "Lib\\pylib"
fi

# Build dir
if $DO_BUILD; then
	vlog "Creating symlinks in $BFPDIR...\n"
	$EXEC rm -f "$BFPDIR/pylib/Games"
	$EXEC rm -f "$BFPDIR/pylib/crispy"
	$EXEC cmd /c mklink /d "$WBFPDIR\\pylib\\crispy" "$WDOCDIR\\Lib\\pylib"
	$EXEC cmd /c mklink /d "$WBFPDIR\\pylib\\Games" "$WDOCDIR\\Games"
fi

