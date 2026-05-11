import Foundation

protocol KiteManagerProtocol {
    func syncKiteStatesWithRentals() async throws
    func getAllKites() async throws -> [DBKite]
    func createNewKite(kite: DBKite) async throws
    func updateKiteState(kiteId: String, state: KiteState) async throws
    func updateKiteFields(kiteId: String, fields: [String: Any]) async throws
    func deleteKite(kiteId: String) async throws
}

protocol RentalManagerProtocol {
    func getActiveRentals() async throws -> [DBRental]
    func getAllRentals() async throws -> [DBRental]
    func getRentalsForInstructor(instructorId: String) async throws -> [DBRental]
    func createNewRental(rental: DBRental) async throws
    func updateRentalFields(rentalId: String, fields: [String: Any]) async throws
    func hasOverlappingRental(kiteId: String, start: Date, end: Date) async throws -> Bool
}

protocol InstructorManagerProtocol {
    func getAllInstructors() async throws -> [DBInstructor]
    func getInstructor(instructorId: String) async throws -> DBInstructor
    func createInstructor(instructor: DBInstructor) async throws
    func updateInstructorFields(instructorId: String, fields: [String: Any]) async throws
    func deleteInstructor(instructorId: String) async throws
}

extension KiteManager: KiteManagerProtocol {}
extension RentalManager: RentalManagerProtocol {}
extension InstructorManager: InstructorManagerProtocol {}

protocol AuthenticationManagerProtocol {
    func getAuthenticatedUser() throws -> AuthDataResultModel
    func createUser(email: String, password: String) async throws -> AuthDataResultModel
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel
    func signOut() throws
    func reauthenticateUser(email: String, password: String) async throws
    func updatePassword(to newPassword: String) async throws
}

protocol UserManagerProtocol {
    func createNewUser(user: DBUser) async throws
    func getUser(userId: String) async throws -> DBUser
    func deleteUser(userId: String) async throws
}

extension AuthenticationManager: AuthenticationManagerProtocol {}
extension UserManager: UserManagerProtocol {}
