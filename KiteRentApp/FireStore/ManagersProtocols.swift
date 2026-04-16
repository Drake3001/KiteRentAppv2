import Foundation

protocol KiteManagerProtocol {
    func syncKiteStatesWithRentals() async throws
    func getAllKites() async throws -> [DBKite]
    func updateKiteState(kiteId: String, state: KiteState) async throws
}

protocol RentalManagerProtocol {
    func getActiveRentals() async throws -> [DBRental]
    func getAllRentals() async throws -> [DBRental]
    func createNewRental(rental: DBRental) async throws
}

protocol InstructorManagerProtocol {
    func getAllInstructors() async throws -> [DBInstructor]
}

extension KiteManager: KiteManagerProtocol {}
extension RentalManager: RentalManagerProtocol {}
extension InstructorManager: InstructorManagerProtocol {}
