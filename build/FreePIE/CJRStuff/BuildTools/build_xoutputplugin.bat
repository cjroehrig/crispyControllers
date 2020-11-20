rem CJR(2020): build XOutputPlugin

rem go to current folder
cd %~dp0

call CJRSetupBuild.bat
msbuild XOutputPlugin.sln

