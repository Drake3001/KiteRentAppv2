import Foundation

protocol KiteManagerProtocol {
    func syncKiteStatesWithRentals() async throws
    func getAllKites() async throws -> [DBKite]
}

protocol RentalManagerProtocol {
    func getActiveRentals() async throws -> [DBRental]
    func getAllRentals() async throws -> [DBRental]
}

protocol InstructorManagerProtocol {
    func getAllInstructors() async throws -> [DBInstructor]
}

extension KiteManager: KiteManagerProtocol {}
extension RentalManager: RentalManagerProtocol {}
extension InstructorManager: InstructorManagerProtocol {}
