@echo off
setlocal

title Instalacja kompilatora C++

echo Wybierz zaleznosci do instalacji:
echo   1. GUI i shell (kompilator + Qt 6)
echo   2. Tylko shell (sam kompilator)
choice /c 12 /n /m "Twoj wybor [1/2]: "
set "PAKIET_GUI="
if errorlevel 2 goto wybor_gotowy
set "PAKIET_GUI=mingw-w64-ucrt-x86_64-qt6-base mingw-w64-ucrt-x86_64-pkgconf"
:wybor_gotowy

echo Sprawdzanie winget...
where winget >nul 2>nul
if errorlevel 1 (
    echo Nie znaleziono winget.
    echo Zaktualizuj App Installer w Microsoft Store albo zainstaluj MSYS2 recznie: https://www.msys2.org/
    echo.
    pause
    exit /b 1
)

echo Instalowanie MSYS2...
winget install --id MSYS2.MSYS2 --exact --accept-package-agreements --accept-source-agreements --silent
if errorlevel 1 (
    if not exist "C:\msys64\usr\bin\bash.exe" (
        echo Instalacja MSYS2 nie powiodla sie.
        echo.
        pause
        exit /b 1
    )
)

if not exist "C:\msys64\usr\bin\bash.exe" (
    echo Nie znaleziono MSYS2 w domyslnym folderze C:\msys64.
    echo Uruchom instalator MSYS2 ponownie i wybierz C:\msys64.
    echo.
    pause
    exit /b 1
)

echo Aktualizowanie MSYS2. To moze chwile potrwac...
"C:\msys64\usr\bin\bash.exe" -lc "pacman -Syu --noconfirm"
if errorlevel 1 (
    echo Aktualizacja MSYS2 nie powiodla sie. Uruchom ten plik ponownie.
    echo.
    pause
    exit /b 1
)

"C:\msys64\usr\bin\bash.exe" -lc "pacman -Syu --noconfirm"
if errorlevel 1 (
    echo Aktualizacja MSYS2 nie powiodla sie. Uruchom ten plik ponownie.
    echo.
    pause
    exit /b 1
)

echo Instalowanie kompilatora g++...
"C:\msys64\usr\bin\bash.exe" -lc "pacman -S --needed --noconfirm mingw-w64-ucrt-x86_64-gcc %PAKIET_GUI%"
if errorlevel 1 (
    echo Instalowanie kompilatora lub wybranych bibliotek nie powiodlo sie.
    echo.
    pause
    exit /b 1
)

if not exist "C:\msys64\ucrt64\bin\g++.exe" (
    echo Nie znaleziono g++.exe po instalacji.
    echo.
    pause
    exit /b 1
)

echo Dodawanie kompilatora do PATH uzytkownika...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $bin='C:\msys64\ucrt64\bin'; try { $parts=@([Environment]::GetEnvironmentVariable('Path','User') -split ';' | Where-Object { $_ }); if ($parts -notcontains $bin) { $parts += $bin }; [Environment]::SetEnvironmentVariable('Path', ($parts -join ';'), 'User') } catch { Write-Error $_; exit 1 }"
if errorlevel 1 (
    echo Nie udalo sie zmienic PATH uzytkownika.
    echo Mozesz uruchomic start.bat, ktory szuka kompilatora w C:\msys64.
    echo.
    pause
    exit /b 1
)

set "PATH=C:\msys64\ucrt64\bin;%PATH%"
echo.
echo Gotowe! Wybrane zaleznosci sa zainstalowane.
echo Uruchom start.bat i wybierz wariant gry.
echo.
pause
