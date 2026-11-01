# Ciepło czy zimno?

Gra polega na odgadnięciu wylosowanej liczby z zakresu od 1 do 10 000.
Po każdym pudle program informuje, czy kolejny strzał jest bliżej celu,
i zawęża możliwy zakres.

## Open source

Projekt jest udostępniony na licencji [MIT](LICENSE). Możesz go używać,
kopiować, modyfikować i rozpowszechniać zgodnie z jej warunkami.
Licencja obejmuje oryginalny kod i dokumentację tego repozytorium.

Pyreczka's Hobby Studio to nazwa hobbystyczna, nie firma ani
zarejestrowana działalność gospodarcza.

Kod źródłowy gry, konfiguracja budowania i testy są dostępne w repozytorium.
Pliki wykonywalne są kompilowane lokalnie i nie są częścią repozytorium.
Zewnętrzne narzędzia i biblioteki zachowują własne licencje:

- kompilator C++ i narzędzia budowania — licencje ich dostawców;
- Qt 6 Widgets dla wersji GUI — licencja wybrana dla używanej dystrybucji Qt
  (m.in. LGPL/GPL lub komercyjna);
- pakiety instalowane przez `dodajkompilatora.sh` lub `dodajkompilatora.bat` —
  licencje dostarczane przez ich projekty i dystrybucje.

Wkład w projekt jest mile widziany. Zasady zgłaszania zmian opisuje
[CONTRIBUTING.md](CONTRIBUTING.md).

## Wersje gry

| Wersja | Opis |
| --- | --- |
| GUI | Okno graficzne oparte na Qt 6 Widgets. Enter zatwierdza strzał. |
| Shell | Wersja terminalowa, bez zależności od Qt ani środowiska graficznego. |

W shellu wpisz `N`, aby od razu rozpocząć nową rundę, albo `Q`, aby zakończyć.
Po odgadnięciu liczby kolejna runda rozpoczyna się automatycznie. W GUI nową
grę rozpoczyna przycisk **Nowa gra**.

## Windows

1. Uruchom `dodajkompilatora.bat`.
2. Wybierz instalację GUI i shell albo samego shella. Instalator używa MSYS2.
3. Uruchom `start.bat`. Skrypt buduje wersje, dla których są dostępne zależności,
   a potem pozwala wybrać, którą uruchomić.

Pliki wynikowe trafiają do katalogu głównego projektu:

- `gra-gui.exe`
- `gra-shell.exe`

GUI wymaga Qt 6 Widgets i `pkg-config`. Jeśli Qt nie jest zainstalowane,
skrypt poinformuje o tym i zbuduje shell. Aby uruchomić tylko wersję terminalową,
użyj `start.bat shell`.

## Linux

### Arch Linux i pochodne: pakiet makepkg

Z katalogu głównego projektu zainstaluj narzędzia pakietu bazowego, a następnie
zbuduj i zainstaluj pakiet:

```sh
sudo pacman -S --needed base-devel
makepkg -si
```

`PKGBUILD` buduje obie wersje i instaluje polecenia `startgra` oraz
`startgra-gui`. Zależność Qt 6 jest deklarowana w pakiecie i instalowana przez
`makepkg -s`. Pakiet można później usunąć przez menedżer pakietów:

```sh
sudo pacman -R cieplo-czy-zimno
```

### Instalacja poleceń systemowych

GNU Make musi być dostępny przed użyciem poniższych poleceń. W katalogu
projektu wykonaj:

```sh
make
make test
make install
```

`make` kompiluje dostępne wersje, a `make test` uruchamia testy logiki.
`make install` wykrywa dystrybucję i przez
`dodajkompilatora.sh` instaluje kompilator C++ oraz zależności Qt 6, buduje
wersje GUI i shell, a następnie instaluje je w `/usr/local/bin`.
Instalator poprosi o uprawnienia przez `doas` lub `sudo` (albo użyje ich
bezpośrednio, jeśli polecenie uruchomiono jako root). Po instalacji można
uruchamiać grę z dowolnego katalogu:

```sh
startgra
startgra-gui
```

Polecenie `startgra` uruchamia wersję terminalową, a `startgra-gui` wersję
graficzną. Jeśli używasz innego prefiksu instalacji, możesz go ustawić, np.
`make install PREFIX="$HOME/.local"`; katalog `bin` tego prefiksu musi być
dostępny w `PATH`. Do usunięcia zainstalowanych poleceń użyj `make uninstall`.

### Ręczne budowanie i uruchamianie

Skrypty korzystają z Bash. Możesz uruchomić je bez ustawiania praw wykonywania:

```sh
bash dodajkompilatora.sh
bash start.sh
```

Albo ustawić prawa i uruchamiać bezpośrednio:

```sh
chmod +x dodajkompilatora.sh start.sh
./dodajkompilatora.sh
./start.sh
```

Instalator odczytuje `/etc/os-release` i dobiera rodzinę menedżera pakietów.
Do instalacji z uprawnieniami administratora używa `doas`, `sudo` albo
bezpośrednio poleceń, jeśli został uruchomiony jako root.
Jeśli dystrybucji nie uda się rozpoznać, wyświetli menu, w którym można wskazać
najbliższą rodzinę:

| Wybór | Dystrybucje (przykłady) | Menedżer |
| --- | --- | --- |
| 1 | Debian, Ubuntu, Linux Mint | APT |
| 2 | Arch Linux, Manjaro, EndeavourOS | Pacman |
| 3 | Gentoo | Portage |
| 4 | Fedora, RHEL, Rocky Linux, AlmaLinux | DNF lub YUM |
| 5 | Alpine Linux | APK |
| 6 | openSUSE Leap, Tumbleweed | Zypper |
| 7 | Void Linux | XBPS |
| 8 | Inna dystrybucja — instrukcja ręczna | — |

Najpierw wybierz, czy instalować GUI i shell, czy sam shell. Dla nieznanej
dystrybucji wybierz rodzinę z powyższej tabeli. Wybór 8 kończy instalator bez
zmian w systemie i podaje wymagania do ręcznej instalacji.

### Debian i Ubuntu

GUI i shell:

```sh
sudo apt update
sudo apt install g++ pkg-config qt6-base-dev
```

Tylko shell:

```sh
sudo apt update
sudo apt install g++
```

### Gentoo

Instalator obsługuje zarówno `doas`, jak i `sudo`. Dla GUI instaluje Qt 6 oraz
pakiet platformy Wayland. Backend X11/Wayland wybierany jest przez Qt na podstawie
bieżącej sesji.

Aby włączyć oba backendy w Qt 6, dodaj do `/etc/portage/package.use/qt6`:

```text
dev-qt/qtbase X wayland widgets opengl
```

Po zmianie USE flags przebuduj zależności Qt:

```sh
sudo emerge --ask --update --deep --newuse @world
```

Jeśli używasz `doas`, zamień `sudo` na `doas`. X11 wymaga USE flagi `X`;
Wayland wymaga flag `wayland` i `opengl` oraz pakietu `dev-qt/qtwayland:6`.

#### Budowanie i uruchamianie skryptem

`start.sh` buduje `gra-shell-linux` w katalogu głównym projektu, a jeśli wykryje
Qt 6 Widgets, także `gra-gui-linux`. Nazwy plików wykonywalnych na Linuksie nie
mają rozszerzenia.
Po kompilacji skrypt wyświetla menu uruchamiania.

Możesz też wybrać działanie argumentem:

```sh
bash start.sh gui
bash start.sh shell
bash start.sh build
```

`gui` wymaga Qt 6 Widgets. `shell` buduje i uruchamia tylko terminalową wersję.
`build` buduje dostępne wersje i kończy pracę bez uruchamiania gry.
Zwykły wariant `gui` pozwala Qt automatycznie dobrać backend do sesji X11 lub
Wayland. Możesz też wymusić konkretny backend:

```sh
bash start.sh gui-x11
bash start.sh gui-wayland
```

Wymuszenie ustawia `QT_QPA_PLATFORM`: `xcb` dla X11 albo `wayland` dla Wayland.
W systemie muszą być zainstalowane odpowiednie wtyczki platformy Qt.

## CMake

Alternatywnie projekt można zbudować przez CMake:

```sh
cmake -S pliki -B pliki/build
cmake --build pliki/build
ctest --test-dir pliki/build --output-on-failure
```

Programy zbudowane przez CMake również trafiają do katalogu głównego projektu.
Jeśli Qt 6 Widgets nie jest dostępne, CMake pomija GUI i buduje wersję shell.
Backend X11/Wayland dostarcza instalacja Qt systemu; CMake nie wymaga osobnych
flag linkera dla tych platform.

## Struktura projektu

- `pliki/gra.cpp` — graficzny interfejs Qt;
- `pliki/gra_shell.cpp` — wersja terminalowa;
- `pliki/gra_logika.h` — wspólna logika gry;
- `pliki/tests/` — testy logiki;
- `.github/workflows/` — automatyczne budowanie i testowanie na Windowsie i Linuksie.

## Rozwiązywanie problemów

- **`env: 'bash\r': No such file or directory`** — skrypty `.sh` powinny mieć
  zakończenia linii LF. Repozytorium ustawia ten format przez `.gitattributes`.
  Po pobraniu na Windowsie można uruchomić je w WSL poleceniem `bash start.sh`.
- **Brak Qt 6 Widgets** — uruchom `bash dodajkompilatora.sh`, wybierz GUI i shell
  albo zainstaluj pakiety Qt 6 dla swojej dystrybucji.
- **Nieznany menedżer pakietów** — wybierz rodzinę dystrybucji z menu instalatora
  lub zainstaluj ręcznie kompilator C++17; GUI wymaga dodatkowo `pkg-config`
  i Qt 6 Widgets.
