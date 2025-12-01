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
        }
    }
    
    /// Zatrzymuje wszystkie listenery
    func stopListening() {
        kiteListener?.remove()
        kiteListener = nil
        
        rentalListener?.remove()
        rentalListener = nil
    }
    
    private func setupKiteListener() {
        kiteListener = KiteManager.shared.listenToKites { [weak self] result in
            Task { @MainActor [weak self] in
                switch result {
                case .success(let kites):
                    self?.kites = kites
                    self?.isLoading = false
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.isLoading = false
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
        
        self.activeRentals = rentalsMap
    }
    
    deinit {
        stopListening()
    }
}
