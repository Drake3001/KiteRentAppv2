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

    @Published var selectedKite: DBKite? = nil
    @Published var showPopup: Bool = false
    @Published var showScanner: Bool = false
    @Published var showErrorAlert: Bool = false

    /// Bumped when kites are reloaded so `MediaImageView` can refresh from SwiftData.
    @Published var mediaRefreshToken: UUID = UUID()

    private var rentalRefreshTask: Task<Void, Never>? = nil

    private let kiteManager: KiteManagerProtocol
    private let rentalManager: RentalManagerProtocol
    private let instructorManager: InstructorManagerProtocol

    init(kiteManager: KiteManagerProtocol? = nil,
         rentalManager: RentalManagerProtocol? = nil,
         instructorManager: InstructorManagerProtocol? = nil) {
        self.kiteManager = kiteManager ?? KiteManager.shared
        self.rentalManager = rentalManager ?? RentalManager.shared
        self.instructorManager = instructorManager ?? InstructorManager.shared
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
            sizeSorted = base.sorted { (Double($0.size) ?? 0) < (Double($1.size) ?? 0) }
        } else {
            sizeSorted = base.sorted { (Double($0.size) ?? 0) > (Double($1.size) ?? 0) }
        }

        return sizeSorted.sorted { $0.state < $1.state }
    }

    func getInstructorForKite(kiteId: String) -> DBInstructor? {
        return activeRentals[kiteId]
    }

    func selectKite(_ kite: DBKite) {
        selectedKite = kite
        showPopup = kite.state == .free
    }

    func handleScannedKite(kiteId: String) {
        guard let kite = filteredAndOrderedKites.first(where: { $0.id == kiteId }) else {
            errorMessage = "Nie znaleziono kite o ID \(kiteId)."
            showErrorAlert = true
            return
        }
        switch kite.state {
        case .free:
            selectedKite = kite
            showPopup = true
        case .used:
            errorMessage = "Kite \(kiteId) jest zajęty."
            showErrorAlert = true
        case .serviced:
            errorMessage = "Kite \(kiteId) jest niedostępny."
            showErrorAlert = true
        }
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
        mediaRefreshToken = UUID()
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
        rentalRefreshTask?.cancel()
        rentalRefreshTask = nil
    }
}

