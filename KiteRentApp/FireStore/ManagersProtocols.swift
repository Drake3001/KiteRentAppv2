import Foundation

protocol KiteManagerProtocol {
    func syncKiteStatesWithRentals() async throws
    func getAllKites() async throws -> [DBKite]
    func updateKiteState(kiteId: String, state: KiteState) async throws
    func updateKiteFields(kiteId: String, fields: [String: Any]) async throws
    func deleteKite(kiteId: String) async throws
}

protocol RentalManagerProtocol {
    func getActiveRentals() async throws -> [DBRental]
    func getAllRentals() async throws -> [DBRental]
    func createNewRental(rental: DBRental) async throws
}

protocol InstructorManagerProtocol {
    func getAllInstructors() async throws -> [DBInstructor]
    func updateInstructorFields(instructorId: String, fields: [String: Any]) async throws
}

extension KiteManager: KiteManagerProtocol {}
extension RentalManager: RentalManagerProtocol {}
extension InstructorManager: InstructorManagerProtocol {}

protocol AuthenticationManagerProtocol {
    func getAuthenticatedUser() throws -> AuthDataResultModel
    func createUser(email: String, password: String) async throws -> AuthDataResultModel
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel
    func signOut() throws
}

protocol UserManagerProtocol {
    func createNewUser(user: DBUser) async throws
    func getUser(userId: String) async throws -> DBUser
}

extension AuthenticationManager: AuthenticationManagerProtocol {}
extension UserManager: UserManagerProtocol {}
