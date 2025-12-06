import Foundation
import Combine

@MainActor
final class KitesurfingListViewModel: ObservableObject {
    @Published var kites: [DBKite] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    @Published var activeRentals: [String: DBInstructor] = [:]
    
//    private var refreshTimer: Timer?
//    private let refreshInterval: TimeInterval = 1 * 60
    
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
            try await
            KiteManager.shared.syncKiteStatesWithRentals()
            
            let fetched = try await
            KiteManager.shared.getAllKites()
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
    
//    func startAutoRefresh() {
//        stopAutoRefresh()
//        
//        refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshInterval, repeats: true) { [weak self] _ in
//            Task { @MainActor [weak self] in
//                await self?.loadKites()
//            }
//        }
//    }
    
//    func stopAutoRefresh() {
//        refreshTimer?.invalidate()
//        refreshTimer = nil
//    }
//    
//    deinit {
//        refreshTimer?.invalidate()
//        refreshTimer = nil
//    }
    
    private var nextRentalTimer: Timer?

    func startRefreshOnRentalEnd() {
        nextRentalTimer?.invalidate()
        Task { @MainActor in
            await scheduleNextRentalRefresh()
        }
    }

    func stopRefreshOnRentalEnd() {
        nextRentalTimer?.invalidate()
        nextRentalTimer = nil
    }

    private func scheduleNextRentalRefresh() async {
        do {
            let activeRentals = try await RentalManager.shared.getActiveRentals()
            let now = Date()
            
            guard let nextRental = activeRentals.min(by: { $0.endTime < $1.endTime }) else { return }
            let interval = nextRental.endTime.timeIntervalSince(now)
            
            guard interval > 0 else {
                await loadKites()
                await scheduleNextRentalRefresh()
                return
            }
            
            nextRentalTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
                Task { @MainActor in
                    await self?.loadKites()
                    await self?.scheduleNextRentalRefresh() 
                }
            }
            RunLoop.main.add(nextRentalTimer!, forMode: .common)
            
        } catch {
            print("Błąd przy pobieraniu aktywnych rentali: \(error)")
        }
    }
    
//    private func scheduleNextRentalRefresh() async {
//        do {
//            let activeRentals = try await RentalManager.shared.getActiveRentals()
//            let now = Date()
//            
//            let upcomingRentals = activeRentals.filter { $0.endTime > now }
//            guard !upcomingRentals.isEmpty else { return }
//
//            let nextEndTime = upcomingRentals.min(by: { $0.endTime < $1.endTime })!.endTime
//            let interval = nextEndTime.timeIntervalSince(now)
//            
//            #if DEBUG
//            print("Next rental ends at: \(nextEndTime), interval: \(interval)s")
//            #endif
//            
//            guard interval > 0 else {
//                await loadKites()
//                await scheduleNextRentalRefresh()
//                return
//            }
//            
//            nextRentalTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
//                Task { @MainActor in
//                    await self?.loadKites()
//                    await self?.scheduleNextRentalRefresh()
//                }
//            }
//            RunLoop.main.add(nextRentalTimer!, forMode: .common)
//            
//        } catch {
//            print("Błąd przy pobieraniu aktywnych rentali: \(error)")
//        }
//    }

    
    deinit {
            nextRentalTimer?.invalidate()
            nextRentalTimer = nil
        }
    
}
