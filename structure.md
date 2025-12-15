# Struktura projektu KiteRentApp

Projekt **KiteRentApp** składa się z głównego katalogu aplikacji, katalogów testowych oraz plików konfiguracyjnych projektu Xcode.

Główna część aplikacji znajduje się w katalogu **`KiteRentApp/`**, który zawiera pliki startowe aplikacji, konfigurację oraz właściwy kod źródłowy. W podkatalogu **`App/`** znajdują się stałe aplikacji, zasoby graficzne (`Assets.xcassets`) oraz plik uruchamiający aplikację.

Katalog **`Features/`** zawiera pliki związane z funkcjonalnościami aplikacji. Obejmuje on widoki administracyjne (logowanie, profile, ustawienia oraz zarządzanie instruktorami, latawcami i wypożyczeniami), widoki przeznaczone dla instruktorów (rezerwacje, listy, skanowanie kodów QR) oraz pomocnicze komponenty interfejsu użytkownika.

W katalogu **`FireStore/`** znajdują się pliki odpowiedzialne za komunikację z bazą danych. Zawiera on definicje obiektów danych oraz menedżery obsługujące użytkowników, instruktorów, latawce i wypożyczenia.

Pliki **`Info.plist`** oraz **`GoogleService-Info.plist`** przechowują konfigurację aplikacji oraz ustawienia integracji z usługami Google i Firebase. Katalog **`Prototypes/`** zawiera prototypowe widoki wykorzystywane podczas tworzenia i testowania aplikacji.

Plik **`KiteRentApp.xcodeproj`** odpowiada za konfigurację projektu w środowisku Xcode.

Katalogi **`KiteRentAppTests/`** oraz **`KiteRentAppTestsv2/`** zawierają testy aplikacji, w tym testy logiki oraz testy uruchamiania aplikacji. Plik **`OpisTestow.md`** opisuje zakres oraz charakter przeprowadzonych testów.
