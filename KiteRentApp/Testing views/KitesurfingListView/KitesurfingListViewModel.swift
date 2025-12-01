import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class KitesurfingListViewModel: ObservableObject {
    @Published var kites: [DBKite] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = true
    @Published var errorMessage: String?
    
    @Published var activeRentals: [String: DBInstructor] = [:]
    
    private var kiteListener: ListenerRegistration?
    private var rentalListener: ListenerRegistration?
    private var instructors: [DBInstructor] = []
    private var syncTimer: Timer?

    var filteredKites: [DBKite] {
        guard !searchText.isEmpty else { return kites }
        return kites.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    func getInstructorForKite(kiteId: String) -> DBInstructor? {
        return activeRentals[kiteId]
    }
    
    /// Uruchamia listenery dla kites i rentals
    func startListening() {
        stopListening()
        
        // Najpierw załaduj instruktorów (tylko raz)
        Task {
            await loadInstructors()
            
            // Następnie uruchom listenery
            setupKiteListener()
            setupRentalListener()
            
            // Uruchom timer do synchronizacji statusów (co minutę)
            startSyncTimer()
        }
    }
    
    /// Zatrzymuje wszystkie listenery
    func stopListening() {
        kiteListener?.remove()
        kiteListener = nil
        
        rentalListener?.remove()
        rentalListener = nil
        
        stopSyncTimer()
    }
    
    private func startSyncTimer() {
        stopSyncTimer()
        
        // Synchronizuj statusy co minutę (sprawdź zakończone rezerwacje)
        syncTimer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.syncUsedKitesWithActiveRentals()
            }
        }
    }
    
    private func stopSyncTimer() {
        syncTimer?.invalidate()
        syncTimer = nil
    }
    
    private func setupKiteListener() {
        kiteListener = KiteManager.shared.listenToKites { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                switch result {
                case .success(let kites):
                    self.kites = kites
                    self.isLoading = false
                    
                    // Synchronizuj statusy - sprawdź czy kites ze statusem "used" mają aktywną rezerwację
                    await self.syncUsedKitesWithActiveRentals()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    /// Synchronizuje wszystkie kites ze statusem "used" z aktywnymi rezerwacjami
    private func syncUsedKitesWithActiveRentals() async {
        let activeKiteIds = Set(activeRentals.keys)
        
        // Sprawdź wszystkie kites ze statusem "used"
        for kite in kites where kite.state == .used {
            // Jeśli kite ma status "used" ale nie ma aktywnej rezerwacji, zmień na free
            if !activeKiteIds.contains(kite.id) {
                do {
                    try await KiteManager.shared.updateKiteState(kiteId: kite.id, state: .free)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func setupRentalListener() {
        rentalListener = RentalManager.shared.listenToActiveRentals { [weak self] result in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                
                switch result {
                case .success(let activeRentals):
                    await self.updateActiveRentalsWithInstructors(activeRentals: activeRentals)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func loadInstructors() async {
        do {
            self.instructors = try await InstructorManager.shared.getAllInstructors()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    private func updateActiveRentalsWithInstructors(activeRentals: [DBRental]) async {
        let instructorMap = Dictionary(uniqueKeysWithValues: instructors.map { ($0.instructorId, $0) })
        
        var rentalsMap: [String: DBInstructor] = [:]
        for rental in activeRentals {
            if let instructor = instructorMap[rental.instructorId] {
                rentalsMap[rental.kiteId] = instructor
            }
        }
        
        // Zapamiętaj poprzednie aktywne rezerwacje
        let previousActiveKiteIds = Set(self.activeRentals.keys)
        let currentActiveKiteIds = Set(activeRentals.map { $0.kiteId })
        
        // Zaktualizuj mapę
        self.activeRentals = rentalsMap
        
        // Synchronizuj statusy kites z aktywnymi rezerwacjami
        await syncKiteStatesWithActiveRentals(
            currentActiveKiteIds: currentActiveKiteIds,
            previousActiveKiteIds: previousActiveKiteIds
        )
    }
    
    /// Synchronizuje statusy kites z aktywnymi rezerwacjami
    private func syncKiteStatesWithActiveRentals(
        currentActiveKiteIds: Set<String>,
        previousActiveKiteIds: Set<String>
    ) async {
        // Kites, które straciły aktywną rezerwację - zmień na free (jeśli były used)
        let lostActiveRental = previousActiveKiteIds.subtracting(currentActiveKiteIds)
        for kiteId in lostActiveRental {
            // Znajdź kite w aktualnej liście
            if let kite = kites.first(where: { $0.id == kiteId }), kite.state == .used {
                // Zmień status na free
                do {
                    try await KiteManager.shared.updateKiteState(kiteId: kiteId, state: .free)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
        
        // Kites, które mają aktywną rezerwację - upewnij się że są used
        for kiteId in currentActiveKiteIds {
            if let kite = kites.first(where: { $0.id == kiteId }), kite.state != .used {
                // Zmień status na used (pomiń jeśli jest serviced)
                if kite.state != .serviced {
                    do {
                        try await KiteManager.shared.updateKiteState(kiteId: kiteId, state: .used)
                    } catch {
                        errorMessage = error.localizedDescription
                    }
                }
            }
        }
        
        // Dodatkowa synchronizacja: sprawdź wszystkie kites ze statusem "used"
        // które nie mają aktywnej rezerwacji (na wypadek gdyby coś przegapiliśmy)
        for kite in kites where kite.state == .used {
            if !currentActiveKiteIds.contains(kite.id) {
                // Kites ma status "used" ale nie ma aktywnej rezerwacji - zmień na free
                do {
                    try await KiteManager.shared.updateKiteState(kiteId: kite.id, state: .free)
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    deinit {
        stopListening()
    }
}
