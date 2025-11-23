//
//  InstructorManager.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 23/11/2025.
//

import Foundation

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
        let snapshot = try await instructorDocument(instructorId: instructorId).getDocument()
        
        guard var data = snapshot.data() else {
            throw URLError(.badServerResponse)
        }
        
        if let timestamp = data["date_created"] as? Timestamp {
            data["date_created"] = timestamp.dateValue().timeIntervalSince1970
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        return try JSONDecoder().decode(DBInstructor.self, from: jsonData)
    }
    
    func getAllInstructors() async throws -> [DBInstructor] {
        let snapshot = try await instructorCollection.getDocuments()
        
        var instructors: [DBInstructor] = []
        
        for document in snapshot.documents {
            var data = document.data()
            
            if let timestamp = data["date_created"] as? Timestamp {
                data["date_created"] = timestamp.dateValue().timeIntervalSince1970
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let instructor = try JSONDecoder().decode(DBInstructor.self, from: jsonData)
            instructors.append(instructor)
        }
        
        return instructors
    }
}
