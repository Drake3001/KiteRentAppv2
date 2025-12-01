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
    
    func getActiveRentals() async throws -> [DBRental] {
        let now = Date()
        let allRentals = try await getAllRentals()
        
        return allRentals.filter { rental in
            rental.endTime > now
        }
    }
    
    func getActiveRentalForKite(kiteId: String) async throws -> DBRental? {
        let now = Date()
        let allRentals = try await getAllRentals()
        
        return allRentals.first { rental in
            rental.kiteId == kiteId && rental.endTime > now
        }
    }
    
    /// Nasłuchuje zmian w aktywnych rezerwacjach (endTime > teraz) i wywołuje callback
    func listenToActiveRentals(completion: @escaping (Result<[DBRental], Error>) -> Void) -> ListenerRegistration {
        // Nasłuchuj wszystkich rezerwacji, filtruj aktywne po stronie klienta
        return rentalCollection.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot else {
                completion(.failure(NSError(domain: "RentalManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No snapshot"])))
                return
            }
            
            do {
                let allRentals = try snapshot.documents.map { document in
                    try document.data(as: DBRental.self)
                }
                
                // Filtruj tylko aktywne rezerwacje (endTime > teraz)
                let now = Date()
                let activeRentals = allRentals.filter { $0.endTime > now }
                
                completion(.success(activeRentals))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
