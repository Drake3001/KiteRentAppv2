//
//  MockInstructorManager.swift
//  KiteRentAppTests
//

import Foundation
@testable import KiteRentApp

final class MockInstructorManager: InstructorManagerProtocol {
    var instructorsToReturn: [DBInstructor] = []
    var shouldThrow = false

    func getAllInstructors() async throws -> [DBInstructor] {
        if shouldThrow { throw NSError(domain: "MockInstructorManager", code: 1) }
        return instructorsToReturn
    }

    func getInstructor(instructorId: String) async throws -> DBInstructor {
        guard let i = instructorsToReturn.first(where: { $0.instructorId == instructorId }) else {
            throw NSError(domain: "MockInstructorManager", code: 2)
        }
        return i
    }

    func createInstructor(instructor: DBInstructor) async throws {}

    func updateInstructorFields(instructorId: String, fields: [String: Any]) async throws {}

    func deleteInstructor(instructorId: String) async throws {}
}
