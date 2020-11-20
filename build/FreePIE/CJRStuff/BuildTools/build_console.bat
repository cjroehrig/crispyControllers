rem CJR(2020): build FreePIE console version

rem go to current folder
cd %~dp0

call CJRSetupBuild.bat
echo on

set ARGS=
set ARGS=%ARGS% /property:OutputTemp=..\OutputTemp
set args=%ARGS% /property:BuildDir=..\Output
set args=%ARGS% /property:Lib=..\Lib
set args=%ARGS% /property:Help=..\FreePIE.Core.Plugins\Help

rem XXX: tried to use vcvarsall but didnt' work:
rem NB: Configuration must match build_console.xml and build_output.xml
rem set args=%ARGS% /property:Configuration=Release
rem set args=%ARGS% /property:Platform=x86

msbuild build_output.xml %ARGS%
msbuild build_console.xml %ARGS%
