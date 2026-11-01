CXX ?= g++
CXXFLAGS ?= -O2 -Wall -Wextra -Wpedantic
PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
INSTALL ?= install
QT_AVAILABLE := $(shell pkg-config --exists Qt6Widgets 2>/dev/null && printf yes)

.PHONY: all install uninstall clean test

all: gra-shell-linux $(if $(QT_AVAILABLE),gra-gui-linux)

gra-shell-linux: pliki/gra_shell.cpp pliki/gra_logika.h
	$(CXX) -std=c++17 $(CXXFLAGS) pliki/gra_shell.cpp -o $@

gra-gui-linux: pliki/gra.cpp pliki/gra_logika.h
	@test -n "$(QT_AVAILABLE)" || { echo "Qt 6 Widgets and pkg-config are required for the GUI." >&2; exit 1; }
	$(CXX) -std=c++17 $(CXXFLAGS) -fPIC pliki/gra.cpp $$(pkg-config --cflags --libs Qt6Widgets) -o $@

install:
	bash ./dodajkompilatora.sh gui
	$(MAKE) all
	@test -x gra-gui-linux || { echo "GUI build unavailable; check the Qt 6 installation." >&2; exit 1; }
	@install_privileged() { \
		if [ -n "$(DESTDIR)" ] || [ "$$(id -u)" -eq 0 ]; then "$$@"; return; fi; \
		target="$(DESTDIR)$(BINDIR)"; \
		while [ ! -e "$$target" ]; do target=$$(dirname "$$target"); done; \
		if [ -w "$$target" ]; then "$$@"; \
		elif command -v doas >/dev/null 2>&1; then doas "$$@"; \
		elif command -v sudo >/dev/null 2>&1; then sudo "$$@"; \
		else echo "Installation needs root, doas, or sudo privileges." >&2; return 1; fi; \
	}; \
	install_privileged $(INSTALL) -D -m 755 gra-shell-linux "$(DESTDIR)$(BINDIR)/startgra" && \
	install_privileged $(INSTALL) -D -m 755 gra-gui-linux "$(DESTDIR)$(BINDIR)/startgra-gui"
	@echo "Installed startgra and startgra-gui in $(DESTDIR)$(BINDIR)"

uninstall:
	@remove_privileged() { \
		if [ -n "$(DESTDIR)" ] || [ "$$(id -u)" -eq 0 ]; then "$$@"; return; fi; \
		target="$(DESTDIR)$(BINDIR)"; \
		while [ ! -e "$$target" ]; do target=$$(dirname "$$target"); done; \
		if [ -w "$$target" ]; then "$$@"; \
		elif command -v doas >/dev/null 2>&1; then doas "$$@"; \
		elif command -v sudo >/dev/null 2>&1; then sudo "$$@"; \
		else echo "Uninstallation needs root, doas, or sudo privileges." >&2; return 1; fi; \
	}; \
	remove_privileged rm -f "$(DESTDIR)$(BINDIR)/startgra" "$(DESTDIR)$(BINDIR)/startgra-gui"

test:
	mkdir -p pliki/build
	$(CXX) -std=c++17 $(CXXFLAGS) pliki/tests/test_gra_logika.cpp -o pliki/build/test-gra-logika
	./pliki/build/test-gra-logika

clean:
	rm -f gra-shell-linux gra-gui-linux
