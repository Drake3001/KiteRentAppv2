# KiteRentApp

Aplikacja iOS do zarzadzania wypozyczaniem kite'ow, rezerwacjami oraz przeplywem pracy instruktorow.

## Technologie

- Swift
- SwiftUI
- Xcode
- Firebase (na podstawie pliku `GoogleService-Info.plist`)

## Struktura projektu

Glowna aplikacja iOS znajduje sie w katalogu `KiteRentApp/`, a testy w:

- `KiteRentAppTests/`
- `KiteRentAppTestsv2/`

Dodatkowe dokumenty projektu:

- `Structure.md`
- `OpisTestow.md`

## Uruchomienie

1. Otworz projekt w Xcode:
   - `KiteRentApp.xcodeproj`
2. Wybierz docelowy symulator lub urzadzenie.
3. Uruchom aplikacje (`Run`).

## Testy

Uruchom testy z poziomu Xcode (`Product` -> `Test`) albo skrotem `Cmd+U`.

## Uwagi

- Upewnij sie, ze konfiguracja Firebase jest poprawna i plik `GoogleService-Info.plist` jest dostepny lokalnie.
- Wspoldziel konfiguracje sekretnych danych przez bezpieczny kanal (nie przez repozytorium).
