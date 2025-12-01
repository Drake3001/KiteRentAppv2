import Foundation
import Combine

@MainActor
final class KitesurfingListViewModel: ObservableObject {
    @Published var kites: [DBKite] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var activeRentals: [String: DBInstructor] = [:]
    
    private var refreshTimer: Timer?
    private let refreshInterval: TimeInterval = 5 * 60 

    var filteredKites: [DBKite] {
        guard !searchText.isEmpty else { return kites }
        return kites.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    func getInstructorForKite(kiteId: String) -> DBInstructor? {
        return activeRentals[kiteId]
    }

    func loadKites() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await KiteManager.shared.syncKiteStatesWithRentals()
            
            let fetched = try await KiteManager.shared.getAllKites()
            self.kites = fetched
            
            await loadActiveRentalsWithInstructors()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func loadActiveRentalsWithInstructors() async {
        do {
            let activeRentalsList = try await RentalManager.shared.getActiveRentals()
            
            let allInstructors = try await InstructorManager.shared.getAllInstructors()
            let instructorMap = Dictionary(uniqueKeysWithValues: allInstructors.map { ($0.instructorId, $0) })
            
            var rentalsMap: [String: DBInstructor] = [:]
            for rental in activeRentalsList {
                if let instructor = instructorMap[rental.instructorId] {
                    rentalsMap[rental.kiteId] = instructor
                }
            }
            
            self.activeRentals = rentalsMap
        } catch {
            self.activeRentals = [:]
        }
    }
    
    func startAutoRefresh() {
        stopAutoRefresh() 
        
        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.loadKites()
            }
        }
    }
    
    func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    deinit {
        stopAutoRefresh()
    }
}
