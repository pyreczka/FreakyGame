@echo off
setlocal
cd /d "%~dp0"
title Gra Cieplo-Zimno

set "GXX=g++"
where g++ >nul 2>nul
if errorlevel 1 (
    if exist "C:\msys64\ucrt64\bin\g++.exe" (
        set "PATH=C:\msys64\ucrt64\bin;%PATH%"
        set "GXX=C:\msys64\ucrt64\bin\g++.exe"
    ) else (
        echo Nie znaleziono kompilatora g++.
        echo Uruchom najpierw dodajkompilatora.bat.
        pause
        exit /b 1
    )
)

set "PROJECT=%~dp0pliki"
set "BIN=%~dp0"

echo Kompilowanie gra-shell.exe...
"%GXX%" -std=c++17 -O2 -Wall -Wextra "%PROJECT%\gra_shell.cpp" -o "%BIN%\gra-shell.exe"
if errorlevel 1 (
    echo Kompilacja gra-shell.exe nie powiodla sie.
    pause
    exit /b 1
)

if /i "%~1"=="shell" goto shell

set "HAVE_QT="
where pkg-config >nul 2>nul
if errorlevel 1 goto noqt
pkg-config --exists Qt6Widgets
if errorlevel 1 goto noqt
for /f "delims=" %%F in ('pkg-config --cflags --libs Qt6Widgets') do set "QT_FLAGS=%%F"

echo Kompilowanie gra-gui.exe...
"%GXX%" -std=c++17 -O2 -Wall -Wextra -mwindows "%PROJECT%\gra.cpp" %QT_FLAGS% -o "%BIN%\gra-gui.exe"
if errorlevel 1 (
    echo Kompilacja gra-gui.exe nie powiodla sie.
    pause
    exit /b 1
)
set "HAVE_QT=1"
goto built

:noqt
echo Qt 6 Widgets nie jest zainstalowane; pomijam GUI.

:built
echo.
echo Pliki wynikowe znajduja sie w "%BIN%".
echo   gra-shell.exe
if defined HAVE_QT echo   gra-gui.exe
if not defined HAVE_QT goto shell_only_menu
echo.
echo Uruchomic? 1. GUI  2. shell  3. tylko kompilacja
choice /c 123 /n /m "Wybor [1/2/3]: "
if errorlevel 3 exit /b 0
if errorlevel 2 goto shell
start "" "%BIN%\gra-gui.exe"
exit /b 0

:shell_only_menu
echo Uruchomic shell? 1. tak  2. tylko kompilacja
choice /c 12 /n /m "Wybor [1/2]: "
if errorlevel 2 exit /b 0

:shell
"%BIN%\gra-shell.exe"
exit /b %errorlevel%
