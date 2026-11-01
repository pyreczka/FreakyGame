#!/usr/bin/env bash
set -euo pipefail

wybor="${1:-}"
if [[ -z "$wybor" ]]; then
    printf 'Wybierz zaleznosci do instalacji:\n  1. GUI i shell (kompilator + Qt 6)\n  2. Tylko shell (kompilator)\n'
    read -r -p 'Twoj wybor [1/2]: ' wybor
fi

case "$wybor" in
    1|gui|GUI) wariant=gui ;;
    2|shell|SHELL) wariant=shell ;;
    *)
        printf 'Nieznany wariant "%s". Wybierz gui albo shell.\n' "$wybor" >&2
        exit 2
        ;;
esac

if [[ -r /etc/os-release ]]; then
    . /etc/os-release
else
    ID=unknown
    ID_LIKE=
    PRETTY_NAME=unknown
fi

dystrybucja="${PRETTY_NAME:-${ID:-unknown}}"
rodzina=unknown
case " ${ID:-} ${ID_LIKE:-} " in
    *" debian "*|*" ubuntu "*) rodzina=debian ;;
    *" arch "*) rodzina=arch ;;
    *" gentoo "*) rodzina=gentoo ;;
    *" fedora "*|*" rhel "*|*" centos "*|*" rocky "*|*" almalinux "*)
        rodzina=fedora
        ;;
    *" alpine "*) rodzina=alpine ;;
    *" opensuse "*|*" opensuse-leap "*|*" opensuse-tumbleweed "*|*" suse "*)
        rodzina=opensuse
        ;;
    *" void "*) rodzina=void ;;
esac

printf 'Wykryty system: %s (rodzina: %s)\n' "$dystrybucja" "$rodzina"

case "$rodzina" in
    debian|arch|gentoo|fedora|alpine|opensuse|void)
        ;;
    *)
        printf '\nNie udalo sie automatycznie rozpoznac dystrybucji.\n'
        printf 'Wybierz rodzine systemu z tabeli:\n'
        printf '  1) Debian / Ubuntu / Linux Mint (APT)\n'
        printf '  2) Arch / Manjaro / EndeavourOS (Pacman)\n'
        printf '  3) Gentoo (Portage)\n'
        printf '  4) Fedora / RHEL / Rocky / AlmaLinux (DNF lub YUM)\n'
        printf '  5) Alpine Linux (APK)\n'
        printf '  6) openSUSE (Zypper)\n'
        printf '  7) Void Linux (XBPS)\n'
        printf '  8) Inna dystrybucja / instrukcja reczna\n'
        read -r -p 'Wybierz [1-8]: ' wybor_dystrybucji
        case "$wybor_dystrybucji" in
            1) rodzina=debian ;;
            2) rodzina=arch ;;
            3) rodzina=gentoo ;;
            4) rodzina=fedora ;;
            5) rodzina=alpine ;;
            6) rodzina=opensuse ;;
            7) rodzina=void ;;
            8) rodzina=manual ;;
            *)
                printf 'Nieprawidlowy wybor. Instalacja anulowana.\n' >&2
                exit 2
                ;;
        esac
        ;;
esac

printf 'Uzyje rodziny pakietow: %s\n' "$rodzina"

if [[ "$rodzina" == manual ]]; then
    printf 'Dla %s zainstaluj recznie kompilator C++17' "$dystrybucja" >&2
    if [[ "$wariant" == gui ]]; then
        printf ', pkg-config i Qt 6 Widgets.\n' >&2
    else
        printf '.\n' >&2
    fi
    exit 1
fi

if [[ "$(id -u)" -eq 0 ]]; then
    podnies_uprawnienia() { "$@"; }
elif command -v doas >/dev/null 2>&1; then
    podnies_uprawnienia() { doas "$@"; }
elif command -v sudo >/dev/null 2>&1; then
    podnies_uprawnienia() { sudo "$@"; }
else
    printf 'Instalacja wymaga uprawnien administratora (root, doas lub sudo).\n' >&2
    printf 'Zainstaluj sudo albo doas i uruchom skrypt ponownie.\n' >&2
    exit 1
fi

if [[ "$rodzina" == debian ]] && command -v apt-get >/dev/null 2>&1; then
    if [[ "$wariant" == gui ]]; then
        pakiety=("g++" "pkg-config" "qt6-base-dev")
    else
        pakiety=("g++")
    fi
    podnies_uprawnienia apt-get update
    podnies_uprawnienia apt-get install -y "${pakiety[@]}"
elif [[ "$rodzina" == arch ]] && command -v pacman >/dev/null 2>&1; then
    if [[ "$wariant" == gui ]]; then
        pakiety=("base-devel" "pkgconf" "qt6-base")
    else
        pakiety=("base-devel")
    fi
    podnies_uprawnienia pacman -S --needed --noconfirm "${pakiety[@]}"
elif [[ "$rodzina" == gentoo ]] && command -v emerge >/dev/null 2>&1; then
    if [[ "$wariant" == gui ]]; then
        pakiety=("sys-devel/gcc" "dev-util/pkgconf" "dev-qt/qtbase:6" "dev-qt/qtwayland:6")
    else
        pakiety=("sys-devel/gcc")
    fi
    podnies_uprawnienia emerge --ask=n "${pakiety[@]}"
    if [[ "$wariant" == gui ]]; then
        printf '\nQt 6 na Gentoo: sprawdz USE flags w /etc/portage/package.use.\n'
        printf 'Dla X11 i Wayland dodaj do /etc/portage/package.use/qt6:\n'
        printf '  dev-qt/qtbase X wayland widgets opengl\n'
        printf 'Nastepnie przebuduj Qt: emerge -avuDN @world\n'
    fi
elif [[ "$rodzina" == fedora ]] && command -v dnf >/dev/null 2>&1; then
    if [[ "$wariant" == gui ]]; then
        pakiety=("gcc-c++" "pkgconf-pkg-config" "qt6-qtbase-devel")
    else
        pakiety=("gcc-c++")
    fi
    podnies_uprawnienia dnf install -y "${pakiety[@]}"
elif [[ "$rodzina" == fedora ]] && command -v yum >/dev/null 2>&1; then
    if [[ "$wariant" == gui ]]; then
        pakiety=("gcc-c++" "pkgconf-pkg-config" "qt6-qtbase-devel")
    else
        pakiety=("gcc-c++")
    fi
    podnies_uprawnienia yum install -y "${pakiety[@]}"
elif [[ "$rodzina" == alpine ]] && command -v apk >/dev/null 2>&1; then
    if [[ "$wariant" == gui ]]; then
        pakiety=("build-base" "g++" "pkgconf" "qt6-qtbase-dev")
    else
        pakiety=("build-base" "g++")
    fi
    podnies_uprawnienia apk add "${pakiety[@]}"
elif [[ "$rodzina" == opensuse ]] && command -v zypper >/dev/null 2>&1; then
    if [[ "$wariant" == gui ]]; then
        pakiety=("gcc-c++" "pkg-config" "qt6-base-devel")
    else
        pakiety=("gcc-c++")
    fi
    podnies_uprawnienia zypper --non-interactive install "${pakiety[@]}"
elif [[ "$rodzina" == void ]] && command -v xbps-install >/dev/null 2>&1; then
    if [[ "$wariant" == gui ]]; then
        pakiety=("gcc" "pkgconf" "qt6-base-devel")
    else
        pakiety=("gcc")
    fi
    podnies_uprawnienia xbps-install -Sy "${pakiety[@]}"
else
    printf 'Nie znaleziono menedzera pakietow dla rodziny "%s" (%s).\n' "$rodzina" "$dystrybucja" >&2
    printf 'Zainstaluj recznie kompilator C++17' >&2
    if [[ "$wariant" == gui ]]; then
        printf ', pkg-config i Qt 6 Widgets.\n' >&2
    else
        printf '.\n' >&2
    fi
    exit 1
fi
printf 'Gotowe. Uruchom "./start.sh" albo wykonaj "make install", aby zainstalowac polecenia startgra i startgra-gui.\n'
