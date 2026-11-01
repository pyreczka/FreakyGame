#include "../gra_logika.h"

#include <cassert>

int main() {
    Gra::GraLiczbowa gra;
    const int sekret = gra.SekretnaLiczba();
    const int pierwszyStrzal = sekret == Gra::GraLiczbowa::minLiczba
        ? Gra::GraLiczbowa::maxLiczba
        : Gra::GraLiczbowa::minLiczba;

    assert(gra.Strzel(pierwszyStrzal) == Gra::WynikStrzalu::Pierwszy);
    assert(gra.LiczbaProb() == 1);
    assert(gra.DolnaGranica() <= sekret);
    assert(gra.GornaGranica() >= sekret);

    const int drugiStrzal = sekret > pierwszyStrzal
        ? pierwszyStrzal + 1
        : pierwszyStrzal - 1;
    const Gra::WynikStrzalu drugiWynik = gra.Strzel(drugiStrzal);
    assert(drugiWynik == Gra::WynikStrzalu::Cieplej ||
           drugiWynik == Gra::WynikStrzalu::Trafiony);
    assert(gra.LiczbaProb() == 2);

    gra.NowaGra();
    assert(!gra.Zakonczona());
    assert(gra.LiczbaProb() == 0);
    assert(gra.DolnaGranica() == Gra::GraLiczbowa::minLiczba);
    assert(gra.GornaGranica() == Gra::GraLiczbowa::maxLiczba);
    return 0;
}
