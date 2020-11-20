rem CJR(2020): Create VersionInfo.xml

rem go to current folder
cd %~dp0

call CJRSetupBuild.bat
echo on
msbuild write_VersionInfo.xml
