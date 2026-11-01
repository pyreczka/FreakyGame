#include "gra_logika.h"

#include <charconv>
#include <iostream>
#include <string>

namespace {

enum class WynikSesji {
    NowaGra,
    Koniec
};

WynikSesji uruchomGre() {
    Gra::GraLiczbowa gra;
    std::cout << "\n=== CIEPLO CZY ZIMNO? ===\n"
              << "Odgadnij liczbe od " << Gra::GraLiczbowa::minLiczba
              << " do " << Gra::GraLiczbowa::maxLiczba << ".\n"
              << "Wpisz N, aby rozpoczac nowa gre, albo Q, aby zakonczyc.\n\n";

    while (!gra.Zakonczona()) {
        std::cout << "Zakres " << gra.DolnaGranica() << " - " << gra.GornaGranica()
                  << " | Proby: " << gra.LiczbaProb() << "\nTwoj strzal: " << std::flush;

        std::string linia;
        if (!std::getline(std::cin, linia)) {
            std::cout << "\nKoniec wejscia.\n";
            return WynikSesji::Koniec;
        }
        if (linia == "q" || linia == "Q") {
            std::cout << "Szukana liczba to " << gra.SekretnaLiczba() << ".\n";
            return WynikSesji::Koniec;
        }
        if (linia == "n" || linia == "N") {
            std::cout << "\nRozpoczynam nowa gre...\n";
            return WynikSesji::NowaGra;
        }

        int strzal = 0;
        const auto wynikParsowania = std::from_chars(
            linia.data(), linia.data() + linia.size(), strzal);
        if (wynikParsowania.ec != std::errc{} ||
            wynikParsowania.ptr != linia.data() + linia.size()) {
            std::cout << "Wpisz jedna liczbe calkowita albo q.\n\n";
            continue;
        }
        if (strzal < gra.DolnaGranica() || strzal > gra.GornaGranica()) {
            std::cout << "Liczba jest poza aktualnym zakresem; proba nie zostala policzona.\n\n";
            continue;
        }

        const Gra::WynikStrzalu wynik = gra.Strzel(strzal);
        if (wynik == Gra::WynikStrzalu::Trafiony) {
            std::cout << "\nBRAWO! Zgadles liczbe " << gra.SekretnaLiczba()
                      << " w " << gra.LiczbaProb()
                      << (gra.LiczbaProb() == 1 ? " probie!\n\n" : " probach!\n\n");
            return WynikSesji::NowaGra;
        }

        switch (wynik) {
        case Gra::WynikStrzalu::Pierwszy:
            std::cout << "Pierwszy strzal. ";
            break;
        case Gra::WynikStrzalu::Cieplej:
            std::cout << "CIEPLEJ! ";
            break;
        case Gra::WynikStrzalu::Zimniej:
            std::cout << "ZIMNIEJ! ";
            break;
        case Gra::WynikStrzalu::TakSamo:
            std::cout << "Tak samo cieplo. ";
            break;
        case Gra::WynikStrzalu::Trafiony:
            break;
        }
        std::cout << (strzal < gra.SekretnaLiczba()
            ? "Szukana liczba jest wieksza.\n\n"
            : "Szukana liczba jest mniejsza.\n\n");
    }
    return WynikSesji::Koniec;
}

} // namespace

int main() {
    while (true) {
        if (uruchomGre() == WynikSesji::Koniec) {
            break;
        }
    }

    std::cout << "Do zobaczenia!\n";
    return 0;
}
