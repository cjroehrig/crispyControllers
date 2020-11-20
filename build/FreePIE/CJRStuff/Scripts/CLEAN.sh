#!/bin/bash
##########################################################################
# CLEAN:  get rid of object files

if [ -z "$1" ]; then
	echo "Usage $0 <dir>  # cleans up object stuff in <dir>"
	exit 1
fi

cd "$1"

rm -rfv Output
rm -rfv OutputTemp
find . -name "obj" -prune -exec rm -rfv {} \;
find . -name "bin" -prune -exec rm -rfv {} \;

