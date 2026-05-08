import Foundation
import Combine

struct InstructorRental: Identifiable {
    let rentalId: String
    let kiteId: String
    let kiteName: String
    let startTime: Date
    let endTime: Date

    var id: String { rentalId }
}

/// Owned by `InstructorProfileView`: instructor name for the header and today’s schedule for the dashboard tab.
@MainActor
final class InstructorProfileViewModel: ObservableObject {

    @Published private(set) var instructor: DBInstructor?
    @Published private(set) var todaysRentals: [InstructorRental] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    @Published var selectedRental: InstructorRental?
    @Published var isEditPopupPresented: Bool = false
    @Published var actionErrorMessage: String?
    /// Bumped when rentals are reloaded so `MediaImageView` can refresh.
    @Published var mediaRefreshToken: UUID = UUID()

    private let authManager: AuthenticationManagerProtocol
    private let instructorManager: InstructorManagerProtocol
    private let rentalManager: RentalManagerProtocol
    private let kiteManager: KiteManagerProtocol

    init(
        authManager: AuthenticationManagerProtocol? = nil,
        instructorManager: InstructorManagerProtocol? = nil,
        rentalManager: RentalManagerProtocol? = nil,
        kiteManager: KiteManagerProtocol? = nil
    ) {
        self.authManager = authManager ?? AuthenticationManager.shared
        self.instructorManager = instructorManager ?? InstructorManager.shared
        self.rentalManager = rentalManager ?? RentalManager.shared
        self.kiteManager = kiteManager ?? KiteManager.shared
    }

    func loadProfile() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        do {
            let uid = try authManager.getAuthenticatedUser().uid

            instructor = try await instructorManager.getInstructor(instructorId: uid)

            let rentals = try await rentalManager.getRentalsForInstructor(instructorId: uid)
            let kites = try await kiteManager.getAllKites()
            let kiteMap = Dictionary(uniqueKeysWithValues: kites.map { ($0.id, $0.name) })

            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())

            self.todaysRentals = rentals
                .filter { calendar.isDate($0.startTime, inSameDayAs: today) }
                .sorted { $0.startTime < $1.startTime }
                .map { rental in
                    InstructorRental(
                        rentalId: rental.rentalId,
                        kiteId: rental.kiteId,
                        kiteName: kiteMap[rental.kiteId] ?? "Unknown kite",
                        startTime: rental.startTime,
                        endTime: rental.endTime
                    )
                }
            mediaRefreshToken = UUID()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func openEdit(for rental: InstructorRental) {
        selectedRental = rental
        isEditPopupPresented = true
    }

    func closeEdit() {
        isEditPopupPresented = false
        selectedRental = nil
    }

    func endRental(_ rental: InstructorRental) async {
        do {
            try await rentalManager.updateRentalFields(
                rentalId: rental.rentalId,
                fields: ["end_time": Date()]
            )
            await loadProfile()
        } catch {
            actionErrorMessage = error.localizedDescription
        }
    }

    func updateRentalEndTime(_ rental: InstructorRental, endTime: Date) async {
        do {
            try await rentalManager.updateRentalFields(
                rentalId: rental.rentalId,
                fields: ["end_time": endTime]
            )
            closeEdit()
            await loadProfile()
        } catch {
            actionErrorMessage = error.localizedDescription
        }
    }
}
