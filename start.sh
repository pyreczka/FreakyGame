#!/usr/bin/env bash
set -euo pipefail

root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project="$root/pliki"
bin="$root"
compiler="${CXX:-g++}"
variant="${1:-}"

if ! command -v "$compiler" >/dev/null 2>&1; then
    printf 'Nie znaleziono kompilatora C++ (%s). Uruchom ./dodajkompilatora.sh.\n' \
        "$compiler" >&2
    exit 1
fi

mkdir -p "$bin"
shell="$bin/gra-shell-linux"
gui="$bin/gra-gui-linux"

printf 'Kompilowanie %s...\n' "$shell"
"$compiler" -std=c++17 -O2 -Wall -Wextra \
    "$project/gra_shell.cpp" -o "$shell"

have_gui=0
if command -v pkg-config >/dev/null 2>&1 && pkg-config --exists Qt6Widgets; then
    read -r -a qt_flags <<<"$(pkg-config --cflags --libs Qt6Widgets)"
    printf 'Kompilowanie %s...\n' "$gui"
    "$compiler" -std=c++17 -O2 -Wall -Wextra -fPIC \
        "$project/gra.cpp" "${qt_flags[@]}" -o "$gui"
    have_gui=1
elif [[ "$variant" == gui || "$variant" == GUI || "$variant" == 1 ||
        "$variant" == gui-x11 || "$variant" == gui-wayland ]]; then
    printf 'Brak Qt 6 Widgets. Uruchom ./dodajkompilatora.sh i wybierz GUI.\n' >&2
    exit 1
else
    printf 'Qt 6 Widgets nie jest zainstalowane; pomijam GUI.\n' >&2
fi

printf '\nGotowe pliki:\n  %s\n' "$shell"
if (( have_gui )); then
    printf '  %s\n' "$gui"
fi

if [[ -z "$variant" ]]; then
    if (( have_gui )); then
        read -r -p $'\nUruchomić? 1. GUI  2. shell  3. tylko kompilacja: ' variant
    else
        read -r -p $'\nUruchomić shell? [T/n]: ' variant
        variant="${variant:-shell}"
    fi
fi

case "$variant" in
    1|gui|GUI)
        (( have_gui )) || { printf 'GUI niedostępne bez Qt 6.\n' >&2; exit 1; }
        exec "$gui"
        ;;
    2|shell|SHELL)
        exec "$shell"
        ;;
    gui-x11|GUI-X11)
        (( have_gui )) || { printf 'GUI niedostępne bez Qt 6.\n' >&2; exit 1; }
        QT_QPA_PLATFORM=xcb exec "$gui"
        ;;
    gui-wayland|GUI-WAYLAND)
        (( have_gui )) || { printf 'GUI niedostępne bez Qt 6.\n' >&2; exit 1; }
        QT_QPA_PLATFORM=wayland exec "$gui"
        ;;
    3|build|BUILD)
        exit 0
        ;;
    t|T|y|Y|yes|YES|shell)
        exec "$shell"
        ;;
    n|N|no|NO)
        exit 0
        ;;
    *)
        printf 'Nieznany wybór "%s". Użyj gui, shell, gui-x11, gui-wayland albo build.\n' \
            "$variant" >&2
        exit 2
        ;;
esac
