### KiteRentAppTests

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



