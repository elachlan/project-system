@if not defined _echo @echo off

REM Configures the build environment to be able to build the tree
REM
REM Downloads VSWhere, uses it to find a compatible Visual Studio and call a developer prompt to set the environment.

set RequiredVSVersion=16.0
set DownloadUrl=https://github.com/microsoft/vswhere/releases/download/2.6.7/vswhere.exe
set VSWhereExe=%TEMP%\vswhere.exe

REM Are we already in Developer Command Prompt?
if defined VSINSTALLDIR (
    exit /b 0
)

if not exist "%VSWhereExe%" (
  echo Downloading from %DownloadUrl% to %VSWhereExe% so that we can find Visual Studio
  bitsadmin.exe /transfer "VSWhere.exe" /dynamic /download /priority FOREGROUND %DownloadUrl% %VSWhereExe% > nul || (
    echo Failed to download, check your internet connection.
    exit /b 1
  )
)

REM Find Visual Studio that suits our needs
FOR /F "tokens=* USEBACKQ" %%F IN (`%VSWhereExe% -all -latest -prerelease -property installationPath -requires Microsoft.Component.MSBuild`) DO (
  SET DeveloperCommandPrompt=%%F\Common7\Tools\VsDevCmd.bat
)

if not exist "%DeveloperCommandPrompt%" (
  echo To build this repository, Visual Studio %RequiredVSVersion% must be installed.
  echo.
  echo See https://github.com/dotnet/project-system/blob/master/docs/repo/getting-started.md for more information.
  exit /b 1
)

REM Turn off Developer Command Prompt logo
set __VSCMD_ARG_NO_LOGO=yes
call "%DeveloperCommandPrompt%"

REM WORKAROUND: See https://github.com/dotnet/project-system/issues/5177
SET LIB=