import Foundation
import Combine

struct InstructorRental: Identifiable {
    let rentalId: String
    let kiteName: String
    let startTime: Date
    let endTime: Date

    var id: String { rentalId }
}

@MainActor
final class InstructorProfileViewModel: ObservableObject {

    @Published private(set) var instructor: DBInstructor?
    @Published private(set) var todaysRentals: [InstructorRental] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

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
        errorMessage = nil

        do {
            let uid = try authManager.getAuthenticatedUser().uid

            let fetchedInstructor = try await instructorManager.getInstructor(instructorId: uid)
            self.instructor = fetchedInstructor

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
                        kiteName: kiteMap[rental.kiteId] ?? "Unknown kite",
                        startTime: rental.startTime,
                        endTime: rental.endTime
                    )
                }
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
