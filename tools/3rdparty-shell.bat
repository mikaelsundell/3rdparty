@echo off
rem SPDX-License-Identifier: BSD-3-Clause
setlocal DisableDelayedExpansion

set "configuration=debug"
set "python_name=python_d.exe"
if "%~1"=="" goto select_prefix
if /i "%~1"=="debug" goto select_prefix
if /i not "%~1"=="release" goto usage
set "configuration=release"
set "python_name=python.exe"

:select_prefix
for %%I in ("%~dp0..") do set "repo=%%~fI"
rem Keep the original environment when opening another SDK shell from this one.
if not defined THIRDPARTY_BASE_PATH (
    set "THIRDPARTY_BASE_PATH=%PATH%"
    set "THIRDPARTY_BASE_PYTHONPATH=%PYTHONPATH%"
)
set "THIRDPARTY_PREFIX=%repo%\build\win\x64.%configuration%"
if not exist "%THIRDPARTY_PREFIX%\bin\." goto missing_prefix

rem Use the same CPython installation that configured this prefix.
set "python_root="
if exist "%THIRDPARTY_PREFIX%\CMakeCache.txt" (
    for /f "usebackq tokens=1,* delims==" %%I in ("%THIRDPARTY_PREFIX%\CMakeCache.txt") do (
        for /f "tokens=1 delims=:" %%K in ("%%I") do if "%%K"=="build_python_root" set "python_root=%%J"
    )
)
if defined python_root goto select_python
for /f "delims=" %%I in ('py.exe -3.9 -I -c "import sys; print(sys.base_prefix)" 2^>nul') do set "python_root=%%I"
if defined python_root goto select_python
set "python39=%LocalAppData%\Programs\Python\Python39\python.exe"
if not exist "%python39%" set "python39=python.exe"
for /f "delims=" %%I in ('call "%python39%" -I -c "import sys; print(sys.base_prefix) if sys.version_info[:2] == (3, 9) else None" 2^>nul') do set "python_root=%%I"

:select_python
set "THIRDPARTY_PYTHON="
if defined python_root for %%I in ("%python_root%\%python_name%") do set "THIRDPARTY_PYTHON=%%~fI"
if not defined THIRDPARTY_PYTHON goto missing_python
if not exist "%THIRDPARTY_PYTHON%" goto missing_python

set "THIRDPARTY_DLL_DIRS=%THIRDPARTY_PREFIX%\bin;%THIRDPARTY_PREFIX%\lib;%THIRDPARTY_PREFIX%\site-packages\opentimelineio"
set "PATH=%~dp0win;%THIRDPARTY_DLL_DIRS%;%THIRDPARTY_PREFIX%\ninja;%THIRDPARTY_PREFIX%\libjpeg-turbo\bin;%THIRDPARTY_BASE_PATH%"
set "sdk_pythonpath=%~dp0win;%THIRDPARTY_PREFIX%\site-packages;%THIRDPARTY_PREFIX%\python;%THIRDPARTY_PREFIX%\python\OpenEXR;%THIRDPARTY_PREFIX%\lib\python"
if defined THIRDPARTY_BASE_PYTHONPATH set "sdk_pythonpath=%sdk_pythonpath%;%THIRDPARTY_BASE_PYTHONPATH%"
set "PYTHONPATH=%sdk_pythonpath%"

start "3rdparty Shell (%configuration%)" /d "%repo%" "%ComSpec%" /d /k "prompt [3rdparty %configuration%] $P$G"
exit /b %errorlevel%

:usage
echo Usage: %~nx0 [debug^|release] 1>&2
exit /b 2

:missing_prefix
echo Build prefix not found: "%THIRDPARTY_PREFIX%" 1>&2
echo Run build.bat %configuration% from the repository root first. 1>&2
pause
exit /b 1

:missing_python
echo Could not find Python 3.9 %python_name% for "%THIRDPARTY_PREFIX%". 1>&2
echo Install the matching Python 3.9 interpreter, including debug binaries for Debug. 1>&2
pause
exit /b 1
