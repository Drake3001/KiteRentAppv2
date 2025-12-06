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
}