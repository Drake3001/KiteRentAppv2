//
//  RentalManager.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 23/11/2025.
//

import Foundation
import FirebaseFirestore

final class RentalManager {
    
    static let shared = RentalManager()
    private init() { }
    
    private let rentalCollection = Firestore.firestore().collection("rentals")
    
    private func rentalDocument(rentalId: String) -> DocumentReference {
        rentalCollection.document(rentalId)
    }
    
    func createNewRental(rental: DBRental) async throws {
        try rentalDocument(rentalId: rental.rentalId).setData(from: rental, merge: false)
    }
    
    func getRental(rentalId: String) async throws -> DBRental {
        let snapshot = try await rentalDocument(rentalId: rentalId).getDocument()
        
        guard var data = snapshot.data() else {
            throw URLError(.badServerResponse)
        }
        
        if let startTimestamp = data["start_time"] as? Timestamp {
            data["start_time"] = startTimestamp.dateValue().timeIntervalSince1970
        }
        if let endTimestamp = data["end_time"] as? Timestamp {
            data["end_time"] = endTimestamp.dateValue().timeIntervalSince1970
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
        return try JSONDecoder().decode(DBRental.self, from: jsonData)
    }
    
    func getAllRentals() async throws -> [DBRental] {
        let snapshot = try await rentalCollection.getDocuments()
        
        var rentals: [DBRental] = []
        
        for document in snapshot.documents {
            var data = document.data()
            
            if let startTimestamp = data["start_time"] as? Timestamp {
                data["start_time"] = startTimestamp.dateValue().timeIntervalSince1970
            }
            if let endTimestamp = data["end_time"] as? Timestamp {
                data["end_time"] = endTimestamp.dateValue().timeIntervalSince1970
            }
            
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let rental = try JSONDecoder().decode(DBRental.self, from: jsonData)
            rentals.append(rental)
        }
        
        return rentals
    }
}
