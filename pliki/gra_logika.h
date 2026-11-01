#pragma once

#include <random>

namespace Gra {

enum class WynikStrzalu {
    Trafiony,
    Pierwszy,
    Cieplej,
    Zimniej,
    TakSamo
};

class GraLiczbowa {
public:
    static constexpr int minLiczba = 1;
    static constexpr int maxLiczba = 10000;

    GraLiczbowa() : generator(std::random_device{}()) {
        NowaGra();
    }

    void NowaGra() {
        std::uniform_int_distribution<int> losuj(minLiczba, maxLiczba);
        sekretnaLiczba = losuj(generator);
        dolnaGranica = minLiczba;
        gornaGranica = maxLiczba;
        liczbaProb = 0;
        poprzedniaOdleglosc = 0;
        maPoprzedniStrzal = false;
        zakonczona = false;
    }

    WynikStrzalu Strzel(int strzal) {
        ++liczbaProb;
        if (strzal == sekretnaLiczba) {
            zakonczona = true;
            return WynikStrzalu::Trafiony;
        }

        const int odleglosc = strzal < sekretnaLiczba
            ? sekretnaLiczba - strzal
            : strzal - sekretnaLiczba;
        WynikStrzalu wynik = WynikStrzalu::Pierwszy;
        if (maPoprzedniStrzal) {
            if (odleglosc < poprzedniaOdleglosc) {
                wynik = WynikStrzalu::Cieplej;
            } else if (odleglosc > poprzedniaOdleglosc) {
                wynik = WynikStrzalu::Zimniej;
            } else {
                wynik = WynikStrzalu::TakSamo;
            }
        }

        poprzedniaOdleglosc = odleglosc;
        maPoprzedniStrzal = true;
        if (strzal < sekretnaLiczba) {
            dolnaGranica = strzal + 1;
        } else {
            gornaGranica = strzal - 1;
        }
        return wynik;
    }

    int DolnaGranica() const { return dolnaGranica; }
    int GornaGranica() const { return gornaGranica; }
    int LiczbaProb() const { return liczbaProb; }
    int SekretnaLiczba() const { return sekretnaLiczba; }
    bool Zakonczona() const { return zakonczona; }

private:
    std::mt19937 generator;
    int sekretnaLiczba = minLiczba;
    int dolnaGranica = minLiczba;
    int gornaGranica = maxLiczba;
    int liczbaProb = 0;
    int poprzedniaOdleglosc = 0;
    bool maPoprzedniStrzal = false;
    bool zakonczona = false;
};

} // namespace Gra
