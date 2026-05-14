# Struktura projektu KiteRentApp

Repozytorium składa się z **projektu Xcode** (`KiteRentApp.xcodeproj`), katalogu źródeł aplikacji **`KiteRentApp/`** oraz plików dokumentacyjnych w katalogu głównym. Zależności **Firebase** są pobierane przez **Swift Package Manager** (wpis w projekcie Xcode, lokalna pamięć cache SPM może pojawić się u dewelopera po budowaniu).

---

## Katalog główny repozytorium

| Element | Opis |
|--------|------|
| `KiteRentApp.xcodeproj/` | Konfiguracja projektu, schematy, zależności SPM (m.in. Firebase). |
| `KiteRentApp/` | Cały kod aplikacji SwiftUI, zasoby wbudowane, `Info.plist`. |
| `README.md` | Krótki opis projektu. |
| `OpisTestow.md` | Opis zakresu i charakteru testów. |
| `structure.md` | Ten plik — mapa struktury katalogów. |

Plik **`GoogleService-Info.plist`** jest w `.gitignore` (konfiguracja Firebase lokalnie u dewelopera).

---

## `KiteRentApp/` — aplikacja

```
KiteRentApp/
├── App/                          # punkt wejścia, stałe, katalog zasobów
├── Features/                     # widoki i logika UI według funkcji
├── FireStore/                    # modele danych + menedżery Firebase
├── Persistence/                # SwiftData / media lokalne
├── Prototypes/                   # szkice i eksperymenty UI
├── Info.plist
└── StartScreenView.swift         # ekran startowy (gest → lista)
```

### `App/`

- **`KiteRentApp.swift`** — `@main`, `WindowGroup`, Firebase, `NavigationStack` z `StartScreenView`.
- **`AppConstants.swift`** — stałe aplikacji.
- **`Assets.xcassets/`** — kolory, ikona, obrazy latawców (`kiteImages/`), ikona logowania, ewentualne **Data set** (np. audio tutorialu).

### `Features/`

| Podkatalog | Zawartość (skrót) |
|------------|-------------------|
| **Admin Profile** | `ProfileView`, `ProfileViewModel` — panel admina (zakładki). |
| **Dashboard** | Widoki i modele pulpitu instruktora (`InstructorDashboardView`, karty wypożyczeń, edycja końca wypożyczenia). |
| **Helpers** | Komponenty UI i narzędzia: wyszukiwarka, filtry, media, szkło, tagi itd. |
| **Instructor Profile** | Profil instruktora, nawigacja do ustawień. |
| **Instructors List Admin** | Lista / tworzenie / edycja / usuwanie instruktorów (admin). |
| **Kite List Admin** | Lista / tworzenie / edycja latawców (admin). |
| **Kite Reservation** | Rezerwacja latawca: wybór instruktora, czas, nagłówki, przyciski. |
| **Kites List** | Lista latawców dla użytkownika (`KitesurfingListView`, `InstructorKitesurfingListView`, `KitesurfingListViewModel`). |
| **Login / Authentication** | `DirectAdminLoginView`, `AuthenticationManager`, logowanie. |
| **QRScanning** | Skaner QR, ręczne wpisywanie, generator. |
| **Rental List** | Listy wypożyczeń: widok admina i widok instruktora + view modele. |
| **Settings** | Ustawienia: hasło, profil instruktora, odtwarzanie tutorialu wideo/audio (`SettingsMediaPlayback*`, `InlineAVPlayerViewController`). |
| **Shared** | Współdzielone fragmenty: **`Kite List`** (`KitesurfingListContentView`, `KiteCard`), **`Rental`** (pickery, filtry, karty). |

### `FireStore/`

- **Modele**: `DBKite`, `DBInstructor`, `DBRental`, `DBUser`.
- **Menedżery**: `KiteManager`, `InstructorManager`, `RentalManager`, `UserManager`.
- **Pozostałe**: `ManagersProtocols`, `DocumentReference+AsyncEncodable`.

### `Persistence/Media/`

- SwiftData / repozytorium zasobów multimedialnych (`MediaPersistence`, `MediaRepository`, typy właściciela, `MediaAsset`).

### `Prototypes/`

- Starsze lub eksperymentalne widoki (`KiteListView`, `InstructorListView`, `AddKiteView`, `AddInstructorView`) — nie podłączone do głównego przepływu.

---

## Przepływ nawigacji

1. **`StartScreenView`** → gest w górę → **`KitesurfingListView`** (lista + toolbar: skaner, logowanie).
2. Po zalogowaniu (admin / instruktor) → **`ProfileView`** lub **`InstructorProfileView`** → opcjonalnie **`SettingsView`**.

---

