#!/bin/bash
##########################################################################
# Fetch and patch the FreePIE source

[ -d CJRStuff ] || ( echo "Must be in build/FreePIE root dir"; exit 1 )

# Get FreePIE 
if [ -e FreePIE.GITHUB ]; then
	# Copy from an existing GITHUB archive if it exists
	rm -rf FreePIE
	echo "Copying from FreePIE.GITHUB"
	cp -a FreePIE.GITHUB FreePIE
else
	# otherwise download it from scratch
	echo "Fetching virgin copy from Github"
	git clone 'https://github.com/AndersMalmgren/FreePIE.git'
	echo "Saving virgin copy as FreePIE.GITHUB"
	cp -a FreePIE FreePIE.GITHUB
fi

# Apply patches
NO_PATCHES=( noindexer fileerrs )
PATCHES=( console-joy )
for p in "${PATCHES[@]}"; do 
	p="${p}.patch"
	if [ -e "patches/$p" ]; then
		echo "Applying $p..."
		patch -b -p0 < "patches/$p"
	fi
done

# add Console app, don't build installer:
echo "Installing CJR BuildTools"
cp -piv CJRStuff/BuildTools/* FreePIE/BuildTools

# Fix git path:
GETGIT='FreePIE/BuildTools/get_git_version.xml'
mv $GETGIT{,.ORIG}
cat $GETGIT.ORIG | sed 's/git/\\\\cygwin\\\\bin\\\\git/' > $GETGIT

# add missing file (needed for build to complete error-free)
cp -p CJRStuff/Android/com.freepie.android.imu.apk FreePIE/Lib/Android

# Update any VJoy libraries
for f in vJoyInterface.dll vJoyInterfaceWrap.dll; do
	[ -e "PKG/VJoy/$f" ] && cp -p "PKG/VJoy/$f" FreePIE/Lib/VJoy/
done

# fix execute perms on NuGet.exe
chmod +x FreePIE/.nuget/NuGet.exe

# build the VersionInfo.cs
./FreePIE/BuildTools/build_version.bat

