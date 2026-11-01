pkgname=cieplo-czy-zimno
pkgver=1.0.0
pkgrel=1
pkgdesc='Number guessing game with Qt GUI and terminal interface'
arch=('x86_64' 'aarch64')
license=('MIT')
depends=('qt6-base')
makedepends=('gcc' 'make' 'pkgconf')
source=()
sha256sums=()

prepare() {
    local build_dir="$srcdir/$pkgname-$pkgver"
    mkdir -p "$build_dir/pliki"
    cp "$startdir/Makefile" "$build_dir/Makefile"
    cp "$startdir/LICENSE" "$build_dir/LICENSE"
    cp "$startdir/pliki/gra.cpp" \
       "$startdir/pliki/gra_logika.h" \
       "$startdir/pliki/gra_shell.cpp" \
       "$build_dir/pliki/"
}

build() {
    cd "$srcdir/$pkgname-$pkgver"
    make
}

package() {
    local build_dir="$srcdir/$pkgname-$pkgver"
    install -Dm755 "$build_dir/gra-shell-linux" \
        "$pkgdir/usr/bin/startgra"
    install -Dm755 "$build_dir/gra-gui-linux" \
        "$pkgdir/usr/bin/startgra-gui"
    install -Dm644 "$build_dir/LICENSE" \
        "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
