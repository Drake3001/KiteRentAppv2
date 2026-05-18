# KiteRentApp

Natywna aplikacja iOS do zarządzania wypożyczalnią kitesurfingową — obsługuje latawce, rezerwacje, pracę instruktorów i rolę administratora.

---

## Technologie


| Obszar                | Technologia                                                     |
| --------------------- | --------------------------------------------------------------- |
| Język                 | Swift 5                                                         |
| UI                    | SwiftUI (z mostem UIKit tam, gdzie potrzebny: kamera, AVPlayer) |
| Persystencja lokalna  | SwiftData (media/zdjęcia)                                       |
| Backend               | Firebase: **Auth**, **Firestore**, **Analytics**                |
| Zarządzanie pakietami | Swift Package Manager (wbudowany w projekt Xcode)               |
| Wersja Firebase SDK   | ≥ 12.6.0 (via SPM `upToNextMajorVersion`)                       |
| Minimum iOS           | 26.0                                                            |
| IDE                   | Xcode 26+                                                       |


---

## Wymagania

- **macOS** z zainstalowanym **Xcode 26** lub nowszym
- Konto **Firebase** z projektem iOS skonfigurowanym pod bundle ID `com.blazejkowal.KiteRentApp`
- Włączone w Firebase: **Authentication** (email/hasło) oraz **Firestore Database**
- Plik `**GoogleService-Info.plist`** pobrany z konsoli Firebase (patrz sekcja poniżej)

> Aplikacja jest wyłącznie na **iOS** — brak backendu webowego ani wersji Android.

---

## Konfiguracja Firebase

Aby samodzielnie odtworzyć środowisko:

1. Utwórz nowy projekt na [https://console.firebase.google.com](https://console.firebase.google.com).
2. Dodaj aplikację iOS z bundle ID zgodnym z Xcode (`project.pbxproj`).
3. Pobierz wygenerowany plik `**GoogleService-Info.plist`** i umieść go w katalogu `KiteRentApp/`:
  ```
   KiteRentApp/GoogleService-Info.plist
  ```
4. W Firebase Console włącz:
  - **Authentication → Sign-in method → Email/Password**
  - **Firestore Database** (utwórz bazę, ustaw reguły na odczyt/zapis dla zalogowanych użytkowników)
5. Ręcznie utwórz konta testowe w Firebase Authentication → Users (patrz [Konta testowe](#konta-testowe)) i odpowiadające im dokumenty w kolekcji `users` w Firestore z polem `role` ustawionym na `admin` lub `instructor`.

---

## Uruchomienie projektu

1. Sklonuj repozytorium:
  ```bash
   git clone <adres-repozytorium>
   cd KiteRentAppv2
  ```
2. Otwórz projekt w Xcode:
  ```bash
   open KiteRentApp.xcodeproj
  ```
3. Poczekaj, aż Xcode pobierze zależności SPM (Firebase) — widoczne w pasku postępu.
4. Dodaj `GoogleService-Info.plist` do grupy `KiteRentApp/` w Xcode (lub do katalogu na dysku — patrz wyżej).
5. Wybierz schemat **KiteRentApp** i symulator lub urządzenie z iOS 26+.
6. Uruchom aplikację: `▶ Run` lub `Cmd+R`.

---

## Konta testowe

Aplikacja obsługuje dwie role: **admin** i **instructor**. Utwórz dowolne konta email/hasło w Firebase Authentication, a następnie dodaj dla każdego z nich dokument w kolekcji `users` w Firestore z polem `role` ustawionym na `admin` lub `instructor`.

Po zalogowaniu aplikacja automatycznie kieruje użytkownika do odpowiedniego panelu na podstawie tej roli.

---

## Testy automatyczne

Projekt zawiera target `KiteRentAppTests` z testami XCTest. Testy **nie wymagają połączenia z Firebase** — warstwa sieciowa jest zastąpiona mockami.

### Uruchomienie

- **Xcode:** wybierz schemat **KiteRentApp**, następnie `Product → Test` lub `Cmd+U`
- **Linia poleceń:**
  ```bash
  xcodebuild test \
    -project KiteRentApp.xcodeproj \
    -scheme KiteRentApp \
    -destination 'platform=iOS Simulator,name=iPhone 16'
  ```

### Zakres testów


| Plik                                                | Typ          | Co testuje                                              |
| --------------------------------------------------- | ------------ | ------------------------------------------------------- |
| `PureFunction/KiteReservationTimeTests.swift`       | Jednostkowy  | `clampToWorkHours`, `validMinutes`                      |
| `PureFunction/ChangePasswordValidationTests.swift`  | Jednostkowy  | Siła hasła, dopasowanie, `canSubmit`                    |
| `PureFunction/ModelLogicTests.swift`                | Jednostkowy  | `KiteState`, `MediaAsset.makeStorageKey`, JSON `DBUser` |
| `ViewModel/KitesurfingListViewModelTests.swift`     | Z mockami    | Filtrowanie, sortowanie, `loadKites`                    |
| `ViewModel/KiteReservationViewModelTests.swift`     | Z mockami    | Instruktorzy, `confirmReservation`                      |
| `ViewModel/DirectAdminLoginViewModelTests.swift`    | Z mockami    | Logowanie — puste pola, rola admin/instruktor           |
| `Integration/MediaRepositoryIntegrationTests.swift` | Integracyjny | `MediaRepository` z in-memory SwiftData                 |


---

## Struktura projektu

```
KiteRentAppv2/
├── KiteRentApp.xcodeproj/       # Konfiguracja Xcode, schematy, zależności SPM
├── KiteRentApp/
│   ├── App/
│   │   ├── KiteRentApp.swift    # @main, AppDelegate, Firebase.configure(), SwiftData container
│   │   ├── AppConstants.swift   # Stałe aplikacji (godziny pracy, itp.)
│   │   └── Assets.xcassets/     # Ikony, kolory, obrazy latawców, materiały tutorial
│   ├── Features/
│   │   ├── Admin Profile/       # Panel admina (zakładki: Kites, Instructors, Rentals)
│   │   ├── Dashboard/           # Pulpit instruktora (dzisiejsze wypożyczenia)
│   │   ├── Helpers/             # Wielokrotnego użytku komponenty UI
│   │   ├── Instructor Profile/  # Profil instruktora
│   │   ├── Instructors List Admin/ # CRUD instruktorów (admin)
│   │   ├── Kite List Admin/     # CRUD latawców (admin)
│   │   ├── Kite Reservation/    # Widok rezerwacji latawca
│   │   ├── Kites List/          # Lista latawców (publiczna i instruktora)
│   │   ├── Login/Authentication/ # Logowanie, AuthenticationManager
│   │   ├── QRScanning/          # Skaner QR i generator kodów
│   │   ├── Rental List/         # Listy wypożyczeń (admin i instruktor)
│   │   ├── Settings/            # Ustawienia: hasło, profil, tutorial wideo/audio
│   │   ├── Shared/              # Współdzielone widoki (KiteCard, filtry, pickery)
│   │   └── StartScreenView.swift
│   ├── FireStore/
│   │   ├── DBKite.swift / DBInstructor.swift / DBRental.swift / DBUser.swift
│   │   ├── KiteManager.swift / InstructorManager.swift / RentalManager.swift / UserManager.swift
│   │   └── ManagersProtocols.swift   # Protokoły + rozszerzenia (umożliwiają mockowanie)
│   ├── Persistence/Media/       # SwiftData: MediaAsset, MediaRepository, MediaPersistence
│   ├── Prototypes/              # Eksperymentalne widoki (niepodłączone do głównego przepływu)
│   └── Info.plist
├── KiteRentAppTests/
│   ├── PureFunction/
│   ├── ViewModel/
│   ├── Integration/
│   └── Helpers/                 # TestFixtures, mocki menedżerów
├── README.md
├── structure.md                 # Szczegółowa mapa struktury katalogów
├── OpisTestow.md                # Opis zakresu testów (zaimplementowanych i planowanych)
└── TestyManualne.md             # Macierz testów manualnych
```

---

## Przepływ nawigacji

```
StartScreenView
    └── swipe up ──► KitesurfingListView (lista publiczna)
                         ├── [toolbar: ikona wiatru] ──► QRScannerView
                         ├── tap karta latawca ──────────► KiteReservationView (overlay)
                         └── [toolbar: ikona logowania] ► DirectAdminLoginView
                                   ├── login (admin) ────► ProfileView
                                   │                           ├── Kites tab ──► KiteListAdminView
                                   │                           ├── Instructors ► InstructorListAdminView
                                   │                           ├── Rentals ────► RentalListAdminView
                                   │                           └── ⚙ Settings ► SettingsView
                                   └── login (instructor) ► InstructorProfileView
                                                               ├── Dashboard ──► InstructorDashboardView
                                                               ├── Kites ──────► InstructorKitesurfingTabView
                                                               ├── Rentals ────► RentalListInstructorView
                                                               └── ⚙ Settings ► SettingsView
```

---

## Dokumentacja dodatkowa


| Plik                             | Zawartość                                                   |
| -------------------------------- | ----------------------------------------------------------- |
| `[structure.md](structure.md)`   | Szczegółowa mapa katalogów i opis każdego modułu            |
| `[OpisTestow.md](OpisTestow.md)` | Zakres testów automatycznych (zaimplementowane + planowane) |


