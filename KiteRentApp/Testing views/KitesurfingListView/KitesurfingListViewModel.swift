import Foundation
import Combine

@MainActor
final class KitesurfingListViewModel: ObservableObject {
    @Published var kites: [DBKite] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    @Published var activeRentals: [String: DBInstructor] = [:]

    @Published var isSortAscending: Bool = false

    private var rentalRefreshTask: Task<Void, Never>? = nil

    private let kiteManager: KiteManagerProtocol
    private let rentalManager: RentalManagerProtocol
    private let instructorManager: InstructorManagerProtocol

    init(kiteManager: KiteManagerProtocol = KiteManager.shared,
         rentalManager: RentalManagerProtocol = RentalManager.shared,
         instructorManager: InstructorManagerProtocol = InstructorManager.shared) {
        self.kiteManager = kiteManager
        self.rentalManager = rentalManager
        self.instructorManager = instructorManager
    }

    var filteredAndOrderedKites: [DBKite] {
        let base: [DBKite]
        if searchText.isEmpty {
            base = kites
        } else {
            base = kites.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        let sizeSorted: [DBKite]
        if isSortAscending {
            sizeSorted = base.sorted { (Int($0.size) ?? 0) < (Int($1.size) ?? 0) }
//            sizeSorted = base.sorted { Int($0.size)! < Int($1.size)! }

        } else {
            sizeSorted = base.sorted { (Int($0.size) ?? 0) > (Int($1.size) ?? 0) }
//            sizeSorted = base.sorted { Int($0.size)!  > Int($1.size)! }

        }

        return sizeSorted.sorted { $0.state < $1.state }
    }

    func getInstructorForKite(kiteId: String) -> DBInstructor? {
        return activeRentals[kiteId]
    }

    func loadKites() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            try await kiteManager.syncKiteStatesWithRentals()
            let fetched = try await kiteManager.getAllKites()
            self.kites = fetched
            await loadActiveRentalsWithInstructors()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    private func loadActiveRentalsWithInstructors() async {
        do {
            let activeRentalsList = try await rentalManager.getActiveRentals()
            let allInstructors = try await instructorManager.getAllInstructors()
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

    func startRefreshOnRentalEnd() async {
        await stopRefreshOnRentalEnd()
        rentalRefreshTask = Task { [weak self] in
            await self?.observeRentalEndsLoop()
        }
    }

    func stopRefreshOnRentalEnd() async {
        rentalRefreshTask?.cancel()
        rentalRefreshTask = nil
    }

    private func observeRentalEndsLoop() async {
        while !Task.isCancelled {
            do {
                let activeRentals = try await rentalManager.getActiveRentals()
                guard let nextEnd = activeRentals.min(by: { $0.endTime < $1.endTime })?.endTime else {
                    try await Task.sleep(nanoseconds: 5_000_000_000)
                    continue
                }

                let interval = nextEnd.timeIntervalSinceNow
                if interval > 0 {
                    try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                }

                await loadKites()
            } catch {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
            }
        }
    }

    deinit {
//        Task { await stopRefreshOnRentalEnd() }
        rentalRefreshTask?.cancel()

    }
}

