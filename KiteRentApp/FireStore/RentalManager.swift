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
        try await rentalDocument(rentalId: rentalId).getDocument(as: DBRental.self)
    }
    
    func getAllRentals() async throws -> [DBRental] {
        let snapshot = try await rentalCollection.getDocuments()
        
        return try snapshot.documents.map { document in
            try document.data(as: DBRental.self)
        }
    }
}
