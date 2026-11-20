@echo off
rem SPDX-License-Identifier: BSD-3-Clause
setlocal
if /i "%VSCMD_ARG_TGT_ARCH%"=="x64" goto find_python

set "vswhere=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%vswhere%" goto missing_visual_studio
set "vs_install="
for /f "usebackq delims=" %%I in (`"%vswhere%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "vs_install=%%I"
if not defined vs_install goto missing_visual_studio
if not exist "%vs_install%\Common7\Tools\VsDevCmd.bat" goto missing_visual_studio
call "%vs_install%\Common7\Tools\VsDevCmd.bat" -arch=x64 -host_arch=x64
if errorlevel 1 exit /b %errorlevel%

:find_python
py.exe -3.9 -c "import sys" >nul 2>&1
if not errorlevel 1 goto launcher

set "python39=%LocalAppData%\Programs\Python\Python39\python.exe"
if not exist "%python39%" set "python39=python.exe"
"%python39%" -c "import sys; sys.exit(sys.version_info[:2] != (3, 9))" >nul 2>&1
if errorlevel 1 goto missing_python
"%python39%" "%~dp0build.py" %*
exit /b %errorlevel%

:launcher
py.exe -3.9 "%~dp0build.py" %*
exit /b %errorlevel%

:missing_python
echo Python 3.9 is required. Install Python 3.9 with the Python launcher or put its python.exe on PATH. 1>&2
exit /b 1

:missing_visual_studio
echo Visual Studio or Build Tools with the MSVC x64 C++ tools is required. 1>&2
exit /b 1
