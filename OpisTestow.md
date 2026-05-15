### KiteRentAppTests — zaimplementowane (XCTest)

Uruchomienie: w Xcode wybierz schemat **KiteRentApp** ([KiteRentApp.xcodeproj/xcshareddata/xcschemes/KiteRentApp.xcscheme](KiteRentApp.xcodeproj/xcshareddata/xcschemes/KiteRentApp.xcscheme)), symulator iOS, **Product → Test** (`Cmd+U`). Pakiet testów zależy od aplikacji hosta (`TEST_HOST`); na Windowsie w repozytorium nie ma narzędzia `xcodebuild`.

| Plik | Typ | Zakres |
|------|-----|--------|
| [KiteRentAppTests/PureFunction/KiteReservationTimeTests.swift](KiteRentAppTests/PureFunction/KiteReservationTimeTests.swift) | testy jednostkowe (logika czasu) | `clampToWorkHours`, `validMinutes` |
| [KiteRentAppTests/PureFunction/ChangePasswordValidationTests.swift](KiteRentAppTests/PureFunction/ChangePasswordValidationTests.swift) | testy jednostkowe (UI VM, sync) | `ChangePasswordViewModel` — siła hasła, dopasowanie, `canSubmit` |
| [KiteRentAppTests/PureFunction/ModelLogicTests.swift](KiteRentAppTests/PureFunction/ModelLogicTests.swift) | testy jednostkowe (modele) | `KiteState`, `MediaAsset.makeStorageKey`, JSON `DBUser` |
| [KiteRentAppTests/ViewModel/KitesurfingListViewModelTests.swift](KiteRentAppTests/ViewModel/KitesurfingListViewModelTests.swift) | testy jednostkowe z mockami | filtrowanie, sortowanie, `loadKites` (sukces / błąd sync) |
| [KiteRentAppTests/ViewModel/KiteReservationViewModelTests.swift](KiteRentAppTests/ViewModel/KiteReservationViewModelTests.swift) | testy jednostkowe z mockami | instruktorzy, `confirmReservation` (brak instruktora, konflikt, sukces) |
| [KiteRentAppTests/ViewModel/DirectAdminLoginViewModelTests.swift](KiteRentAppTests/ViewModel/DirectAdminLoginViewModelTests.swift) | testy jednostkowe z mockami | logowanie — puste pola, rola admin / instructor |
| [KiteRentAppTests/Integration/MediaRepositoryIntegrationTests.swift](KiteRentAppTests/Integration/MediaRepositoryIntegrationTests.swift) | testy integracyjne SwiftData | `MediaRepository` z in-memory `ModelContainer` — zapis/odczyt, aktualizacja, miniatura, usuwanie |
| [KiteRentAppTests/Helpers/](KiteRentAppTests/Helpers/) | — | `TestFixtures`, mocki protokołów z `ManagersProtocols` |

Mocki nie używają Firebase — cała warstwa sieciowa jest zastąpiona w testach.

---

### KiteRentAppTests — plan rozszerzenia (niezaimplementowane)

#### AdditionalRentalTests.swift
- Testuje nietypowe i brzegowe przypadki w logice wypożyczeń.
- Sprawdza:
  - Czy ustawiany jest komunikat o błędzie, gdy `KiteManager` rzuca wyjątek podczas synchronizacji.
  - Czy lista aktywnych wypożyczeń jest pusta, gdy `InstructorManager` rzuca wyjątek (i czy nie pojawia się niepotrzebny komunikat o błędzie).
  - Czy nieaktywny instruktor jest uwzględniany w aktywnych wypożyczeniach (obecne zachowanie).
  - Czy w przypadku nakładających się wypożyczeń dla tego samego latawca, ostatni wypożyczający „wygrywa”.
  - Czy mapowanie wielu wypożyczeń przypisuje każdego unikalnego latawca do odpowiedniego instruktora.

#### E2ERentalFlowTests.swift
- Testy end-to-end przepływu wypożyczenia.
- Sprawdza:
  - Czy po rezerwacji i wypożyczeniu stan latawca zmienia się na „używany”, a po zwrocie na „wolny”.
  - Czy metoda pobierania aktywnych wypożyczeń poprawnie filtruje po czasie zakończenia (zwraca tylko aktywne wypożyczenia).

#### KitesurfingListViewModelAsyncTests.swift
- Testuje asynchroniczne ładowanie danych w modelu widoku listy latawców.
- Sprawdza:
  - Czy po załadowaniu danych lista latawców i aktywnych wypożyczeń jest poprawnie zmapowana (czy odpowiedni instruktor jest przypisany do latawca).

#### KitesurfingListViewModelRefreshTests.swift
- Testuje mechanizm odświeżania danych w modelu widoku.
- Sprawdza:
  - Czy pętle odświeżania nie dublują się i można je poprawnie anulować.
  - Czy zakończenie wypożyczenia powoduje natychmiastowe przeładowanie danych.
  - Czy po wygaśnięciu wypożyczenia następuje synchronizacja stanów latawców.

#### KitesurfingListViewModelRentalTests.swift
- Testuje logikę obsługi aktywnych wypożyczeń w modelu widoku.
- Sprawdza:
  - Czy lista aktywnych wypożyczeń jest pusta, gdy nie ma pasujących instruktorów.
  - Czy po załadowaniu danych aktywne wypożyczenia są poprawnie aktualizowane i przypisane do odpowiednich instruktorów.

#### KitesurfingListViewModelTests.swift
- Testuje podstawowe funkcje modelu widoku listy latawców.
- Sprawdza:
  - Filtrowanie latawców po tekście wyszukiwania.
  - Sortowanie latawców po rozmiarze (rosnąco/malejąco).
  - Pobieranie instruktora przypisanego do konkretnego latawca.

---

### KiteRentAppTestsv2

#### KiteRentAppTestsv2LaunchTests.swift
- Testuje uruchamianie aplikacji.
- Sprawdza:
  - Czy aplikacja uruchamia się poprawnie.
  - Czy wykonywany jest zrzut ekranu ekranu startowego po starcie aplikacji.



