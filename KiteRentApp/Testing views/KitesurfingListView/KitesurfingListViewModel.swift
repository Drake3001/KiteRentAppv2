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
    private var cleanupTimer: Timer?
    private var instructors: [DBInstructor] = []

    var filteredKites: [DBKite] {
        guard !searchText.isEmpty else { return kites }
        return kites.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    func getInstructorForKite(kiteId: String) -> DBInstructor? {
        activeRentals[kiteId]
    }

    // MARK: - Start / Stop Listening
    func startListening() {
        stopListening()
        Task {
            await loadInstructors()
            setupKiteListener()
            setupRentalListener()
            startCleanupTimer()
        }
    }

    func stopListening() {
        kiteListener?.remove()
        rentalListener?.remove()
        kiteListener = nil
        rentalListener = nil
        stopCleanupTimer()
    }

    private func loadInstructors() async {
        do {
            instructors = try await InstructorManager.shared.getAllInstructors()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Listeners
    private func setupKiteListener() {
        kiteListener = KiteManager.shared.listenToKites { [weak self] result in
            Task { @MainActor in
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
            Task { @MainActor in
                guard let self = self else { return }
                switch result {
                case .success(let rentals):
                    await self.updateActiveRentalsWithInstructors(activeRentals: rentals)
                    await self.syncKiteStatesWithActiveRentals(activeRentals: rentals)
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func updateActiveRentalsWithInstructors(activeRentals: [DBRental]) async {
        let map = Dictionary(uniqueKeysWithValues: instructors.map { ($0.instructorId, $0) })
        var output: [String: DBInstructor] = [:]
        for rental in activeRentals {
            if let instr = map[rental.instructorId] {
                output[rental.kiteId] = instr
            }
        }
        activeRentals = output
    }

    private func syncKiteStatesWithActiveRentals(activeRentals: [DBRental]) async {
        let activeKiteIds = Set(activeRentals.map { $0.kiteId })
        for kite in kites {
            let shouldBeUsed = activeKiteIds.contains(kite.id)
            if shouldBeUsed && kite.state != .used {
                try? await KiteManager.shared.updateKiteState(kiteId: kite.id, state: .used)
            }
            if !shouldBeUsed && kite.state == .used {
                try? await KiteManager.shared.updateKiteState(kiteId: kite.id, state: .free)
            }
        }
    }

    // MARK: - Cleanup expired rentals
    private func startCleanupTimer() {
        cleanupTimer?.invalidate()
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.cleanupExpiredRentals()
            }
        }
    }

    private func stopCleanupTimer() {
        cleanupTimer?.invalidate()
        cleanupTimer = nil
    }

    private func cleanupExpiredRentals() async {
        do {
            let activeRentals = try await RentalManager.shared.getActiveRentals()
            let now = Date()
            for rental in activeRentals where rental.endTime <= now {
                try? await KiteManager.shared.updateKiteState(kiteId: rental.kiteId, state: .free)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    deinit {
        Task { @MainActor in
            stopListening()
        }
    }
}
