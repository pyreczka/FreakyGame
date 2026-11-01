#include "gra_logika.h"

#include <QApplication>
#include <QFrame>
#include <QLabel>
#include <QLineEdit>
#include <QMainWindow>
#include <QPushButton>
#include <QHBoxLayout>
#include <QString>
#include <QVBoxLayout>
#include <QWidget>

namespace {

class OknoGry final : public QMainWindow {
public:
    OknoGry() {
        setWindowTitle(QStringLiteral("Ciepło czy zimno?"));
        resize(720, 710);
        setMinimumSize(620, 650);
        zbudujInterfejs();
        nowaGra();
    }

private:
    Gra::GraLiczbowa gra;
    QLabel* zakres = nullptr;
    QLabel* liczbaProb = nullptr;
    QLabel* komunikat = nullptr;
    QLineEdit* poleStrzalu = nullptr;
    QPushButton* przyciskStrzalu = nullptr;
    QPushButton* przyciskNowejGry = nullptr;

    QLabel* etykieta(const QString& tekst, const QString& styl, QWidget* rodzic = nullptr) {
        auto* label = new QLabel(tekst, rodzic);
        label->setStyleSheet(styl);
        label->setWordWrap(true);
        return label;
    }

    void zbudujInterfejs() {
        auto* centralny = new QWidget;
        centralny->setObjectName(QStringLiteral("centralny"));
        centralny->setStyleSheet(
            "#centralny { background: qlineargradient(x1:0,y1:0,x2:1,y2:1,"
            "stop:0 #edf4fc, stop:1 #dce8f6); }"
            "QLabel { color: #1e293b; }");
        setCentralWidget(centralny);

        auto* glowny = new QVBoxLayout(centralny);
        glowny->setContentsMargins(30, 28, 30, 24);
        glowny->setSpacing(14);

        auto* naglowek = new QFrame;
        naglowek->setObjectName(QStringLiteral("naglowek"));
        naglowek->setStyleSheet(
            "#naglowek { color: white; border-radius: 20px;"
            "background: qlineargradient(x1:0,y1:0,x2:1,y2:1,"
            "stop:0 #1e3a5f, stop:1 #112645); }"
            "#naglowek QLabel { color: white; background: transparent; }");
        auto* naglowekLayout = new QVBoxLayout(naglowek);
        naglowekLayout->setContentsMargins(26, 22, 26, 22);
        naglowekLayout->setSpacing(8);
        auto* odznaka = etykieta(QStringLiteral("GRA LICZBOWA"),
                                  "color: #cfe1fa; font-size: 11px; font-weight: 700;"
                                  "letter-spacing: 2px;");
        auto* tytul = etykieta(QStringLiteral("Ciepło czy zimno?"),
                                "font-size: 30px; font-weight: 700;");
        auto* opis = etykieta(QStringLiteral("Odgadnij liczbę. Podpowiemy, czy jesteś bliżej celu."),
                               "color: #d2ddef; font-size: 14px;");
        naglowekLayout->addWidget(odznaka);
        naglowekLayout->addWidget(tytul);
        naglowekLayout->addWidget(opis);
        glowny->addWidget(naglowek);

        auto* podpisRozgrywki = etykieta(QStringLiteral("Twoja rozgrywka"),
                                         "font-size: 17px; font-weight: 700;");
        glowny->addWidget(podpisRozgrywki);

        auto* statystyki = new QHBoxLayout;
        statystyki->setSpacing(14);
        auto* zakresFrame = new QFrame;
        auto* probyFrame = new QFrame;
        const QString stylKarty =
            "QFrame { background: #f7f9fc; border: 1px solid #e4eaf2; border-radius: 14px; }";
        zakresFrame->setStyleSheet(stylKarty);
        probyFrame->setStyleSheet(stylKarty);
        auto* zakresLayout = new QVBoxLayout(zakresFrame);
        auto* probyLayout = new QVBoxLayout(probyFrame);
        zakresLayout->setContentsMargins(16, 12, 16, 12);
        probyLayout->setContentsMargins(16, 12, 16, 12);

        auto* podpisZakresu = etykieta(QStringLiteral("AKTUALNY ZAKRES"),
                                        "color: #64748b; font-size: 11px; font-weight: 700;"
                                        "letter-spacing: 1px;");
        zakres = etykieta(QString(), "font-size: 24px; font-weight: 700;");
        auto* podpisProb = etykieta(QStringLiteral("LICZBA PRÓB"),
                                     "color: #64748b; font-size: 11px; font-weight: 700;"
                                     "letter-spacing: 1px;");
        liczbaProb = etykieta(QString(), "font-size: 24px; font-weight: 700;");
        zakresLayout->addWidget(podpisZakresu);
        zakresLayout->addWidget(zakres);
        probyLayout->addWidget(podpisProb);
        probyLayout->addWidget(liczbaProb);
        statystyki->addWidget(zakresFrame);
        statystyki->addWidget(probyFrame);
        glowny->addLayout(statystyki);

        auto* podpisStrzalu = etykieta(QStringLiteral("Twój strzał"),
                                        "font-size: 15px; font-weight: 600;");
        glowny->addWidget(podpisStrzalu);

        auto* wierszWejscia = new QHBoxLayout;
        wierszWejscia->setContentsMargins(10, 8, 10, 8);
        wierszWejscia->setSpacing(12);
        poleStrzalu = new QLineEdit;
        poleStrzalu->setPlaceholderText(QStringLiteral("Wpisz liczbę od 1 do 10000"));
        poleStrzalu->setAlignment(Qt::AlignCenter);
        poleStrzalu->setMaxLength(5);
        poleStrzalu->setStyleSheet(
            "QLineEdit { background: white; color: #1e293b; border: 1px solid #cbd5e1;"
            "border-radius: 10px; padding: 10px 14px; font-size: 20px; }"
            "QLineEdit:focus { border: 2px solid #3b82f6; }");
        przyciskStrzalu = new QPushButton(QStringLiteral("Sprawdź strzał"));
        przyciskStrzalu->setDefault(false);
        przyciskStrzalu->setAutoDefault(false);
        przyciskStrzalu->setStyleSheet(
            "QPushButton { background: #ea580c; color: white; border: 0; border-radius: 10px;"
            "padding: 12px 18px; font-weight: 700; }"
            "QPushButton:hover { background: #f97316; }"
            "QPushButton:pressed { background: #c2410c; }"
            "QPushButton:disabled { background: #94a3b8; }");
        wierszWejscia->addWidget(poleStrzalu, 1);
        wierszWejscia->addWidget(przyciskStrzalu);

        auto* wejscieFrame = new QFrame;
        wejscieFrame->setStyleSheet(
            "QFrame { background: white; border: 1px solid #cbd5e1; border-radius: 14px; }");
        wejscieFrame->setLayout(wierszWejscia);
        glowny->addWidget(wejscieFrame);

        komunikat = etykieta(QString(),
            "background: #f8fafc; border: 1px solid #e2e8f0; border-left: 4px solid #475569;"
            "border-radius: 10px; padding: 14px; color: #475569; font-size: 14px;");
        glowny->addWidget(komunikat);

        auto* stopka = new QHBoxLayout;
        przyciskNowejGry = new QPushButton(QStringLiteral("Nowa gra"));
        przyciskNowejGry->setStyleSheet(
            "QPushButton { background: white; color: #334155; border: 1px solid #cbd5e1;"
            "border-radius: 10px; padding: 11px 20px; font-weight: 700; }"
            "QPushButton:hover { background: #f1f5f9; }");
        auto* wskazowka = etykieta(QStringLiteral("ENTER  ·  zatwierdza strzał"),
                                    "color: #64748b; font-size: 12px;");
        wskazowka->setAlignment(Qt::AlignRight | Qt::AlignVCenter);
        stopka->addWidget(przyciskNowejGry);
        stopka->addStretch();
        stopka->addWidget(wskazowka);
        glowny->addLayout(stopka);

        connect(przyciskStrzalu, &QPushButton::clicked, this, [this] { sprawdzStrzal(); });
        connect(poleStrzalu, &QLineEdit::returnPressed, this, [this] { sprawdzStrzal(); });
        connect(przyciskNowejGry, &QPushButton::clicked, this, [this] { nowaGra(); });
    }

    void pokazKomunikat(const QString& tekst, const QString& kolor) {
        komunikat->setText(tekst);
        komunikat->setStyleSheet(
            QStringLiteral("background: #f8fafc; border: 1px solid #e2e8f0;"
                           "border-left: 4px solid %1; border-radius: 10px; padding: 14px;"
                           "color: %1; font-size: 14px;").arg(kolor));
    }

    void odswiezStatystyki() {
        zakres->setText(QStringLiteral("%1 – %2").arg(gra.DolnaGranica()).arg(gra.GornaGranica()));
        liczbaProb->setText(QString::number(gra.LiczbaProb()));
    }

    void nowaGra() {
        gra.NowaGra();
        poleStrzalu->clear();
        poleStrzalu->setEnabled(true);
        przyciskStrzalu->setEnabled(true);
        odswiezStatystyki();
        pokazKomunikat(QStringLiteral("Wpisz liczbę i zobacz, czy jesteś blisko."), "#475569");
        poleStrzalu->setFocus();
    }

    void sprawdzStrzal() {
        if (gra.Zakonczona()) {
            return;
        }
        bool poprawnaLiczba = false;
        const int strzal = poleStrzalu->text().toInt(&poprawnaLiczba);
        if (!poprawnaLiczba || strzal < gra.DolnaGranica() || strzal > gra.GornaGranica()) {
            pokazKomunikat(QStringLiteral("Podaj liczbę z aktualnego zakresu."), "#b91c1c");
            poleStrzalu->setFocus();
            poleStrzalu->selectAll();
            return;
        }

        const Gra::WynikStrzalu wynik = gra.Strzel(strzal);
        odswiezStatystyki();
        if (wynik == Gra::WynikStrzalu::Trafiony) {
            const QString rezultat = gra.LiczbaProb() == 1
                ? QStringLiteral("Brawo! Zgadłeś liczbę %1 za pierwszym razem!")
                      .arg(gra.SekretnaLiczba())
                : QStringLiteral("Brawo! Zgadłeś liczbę %1 w %2 próbach!")
                      .arg(gra.SekretnaLiczba()).arg(gra.LiczbaProb());
            pokazKomunikat(rezultat, "#15803d");
            poleStrzalu->setEnabled(false);
            przyciskStrzalu->setEnabled(false);
            return;
        }

        QString temperatura;
        QString kolor = "#475569";
        switch (wynik) {
        case Gra::WynikStrzalu::Pierwszy:
            temperatura = QStringLiteral("Pierwszy strzał!");
            break;
        case Gra::WynikStrzalu::Cieplej:
            temperatura = QStringLiteral("Cieplej! Jesteś coraz bliżej.");
            kolor = "#ea580c";
            break;
        case Gra::WynikStrzalu::Zimniej:
            temperatura = QStringLiteral("Zimniej! Spróbuj z drugiej strony.");
            kolor = "#2563eb";
            break;
        case Gra::WynikStrzalu::TakSamo:
            temperatura = QStringLiteral("Tak samo ciepło. Zmień kierunek!");
            break;
        case Gra::WynikStrzalu::Trafiony:
            return;
        }

        const QString kierunek = strzal < gra.SekretnaLiczba()
            ? QStringLiteral("Szukana liczba jest większa.")
            : QStringLiteral("Szukana liczba jest mniejsza.");
        pokazKomunikat(temperatura + QLatin1Char(' ') + kierunek, kolor);
        poleStrzalu->clear();
        poleStrzalu->setFocus();
    }
};

} // namespace

int main(int argc, char* argv[]) {
    QApplication aplikacja(argc, argv);
    OknoGry okno;
    okno.show();
    return aplikacja.exec();
}
