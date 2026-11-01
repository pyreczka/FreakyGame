# Współtworzenie projektu

Dziękujemy za chęć ulepszenia projektu. Zgłoszenia błędów, pomysły i pull
requesty są mile widziane.

## Przed wysłaniem pull requesta

1. Skup zmianę na jednym problemie i opisz jej widoczny efekt.
2. Sprawdź kompilację wersji shell w C++17 z ostrzeżeniami.
3. Jeśli masz Qt 6, sprawdź także kompilację wersji GUI.
4. Uruchom testy logiki:

   ```sh
   cmake -S pliki -B pliki/build
   cmake --build pliki/build
   ctest --test-dir pliki/build --output-on-failure
   ```

5. Nie dodawaj do zmian plików wykonywalnych ani katalogów kompilacji.

Zgłoszenia błędów i pomysłów możesz przesyłać przez szablony GitHub.
W pull requeście podaj krótki opis oraz wyniki wykonanych sprawdzeń.
