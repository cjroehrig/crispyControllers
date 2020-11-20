rem CJR(2020): Set MSBuild environment

rem Path to current Visual Studio
set VC=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community

rem XXX: msbuild doesn't work with this (x86 vs AnyCPU issues)
rem call "%VC%\VC\Auxiliary\Build\vcvarsall.bat" x86 %*

set PATH=%PATH%;%VC%\MSBuild\Current\Bin
