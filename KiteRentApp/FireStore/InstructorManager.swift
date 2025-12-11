//
//  InstructorManager.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 23/11/2025.
//

import Foundation
import FirebaseFirestore

final class InstructorManager {
    
    static let shared = InstructorManager()
    private init() { }
    
    private let instructorCollection = Firestore.firestore().collection("instructors")
    
    private func instructorDocument(instructorId: String) -> DocumentReference {
        instructorCollection.document(instructorId)
    }
    
    func createNewInstructor(instructor: DBInstructor) async throws {
        try instructorDocument(instructorId: instructor.instructorId).setData(from: instructor, merge: false)
    }
    
    func getInstructor(instructorId: String) async throws -> DBInstructor {
        try await instructorDocument(instructorId: instructorId).getDocument(as: DBInstructor.self)
    }
    
    func getAllInstructors() async throws -> [DBInstructor] {
        let snapshot = try await instructorCollection.getDocuments()
        
        return try snapshot.documents.map { document in
            try document.data(as: DBInstructor.self)
        }
    }

    func updateInstructorFields(instructorId: String, fields: [String: Any]) async throws {
        try await instructorDocument(instructorId: instructorId).updateData(fields)
    }

    func updateInstructor(instructor: DBInstructor) throws {
        try instructorDocument(instructorId: instructor.instructorId).setData(from: instructor, merge: true)
    }

    func deleteInstructor(instructorId: String) async throws {
        let allRentals = try await RentalManager.shared.getAllRentals()
        let rentalsToDelete = allRentals.filter { $0.instructorId == instructorId }

        try await withThrowingTaskGroup(of: Void.self) { group in
            for rental in rentalsToDelete {
                group.addTask {
                    try await RentalManager.shared.deleteRental(rentalId: rental.rentalId)
                }
            }
            try await group.waitForAll()
        }

        try await instructorDocument(instructorId: instructorId).delete()
    }
}