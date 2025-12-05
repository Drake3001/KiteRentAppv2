//
//  KiteManager.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 23/11/2025.
//

import Foundation
import FirebaseFirestore

final class KiteManager {
    
    static let shared = KiteManager()
    private init() { }
    
    private let kiteCollection = Firestore.firestore().collection("kites")
    
    private func kiteDocument(kiteId: String) -> DocumentReference {
        kiteCollection.document(kiteId)
    }
    
    func createNewKite(kite: DBKite) async throws {
        try kiteDocument(kiteId: kite.id).setData(from: kite, merge: false)
    }
    
    func getAllKites() async throws -> [DBKite] {
        let snapshot = try await kiteCollection.getDocuments()
        
        return try snapshot.documents.map { document in
            var kite = try document.data(as: DBKite.self)
            // Ensure ID matches document ID for consistency
            kite.id = document.documentID
            return kite
        }
    }

    
    func getKite(kiteId: String) async throws -> DBKite {
        let document = try await kiteDocument(kiteId: kiteId).getDocument()
        var kite = try document.data(as: DBKite.self)
        kite.id = document.documentID
        return kite
    }
    
    func updateKiteState(kiteId: String, state: KiteState) async throws {
        try await kiteDocument(kiteId: kiteId).updateData([
            "state": state.rawValue
        ])
    }
    
    func syncKiteStatesWithRentals() async throws {
            let activeRentals = try await RentalManager.shared.getActiveRentals()
            let activeKiteIds = Set(activeRentals.map { $0.kiteId })
            
            let allKites = try await getAllKites()
            
            for kite in allKites {
                let hasActiveRental = activeKiteIds.contains(kite.id)
                
                if hasActiveRental && kite.state != .used {
                    try await updateKiteState(kiteId: kite.id, state: .used)
                }
                else if !hasActiveRental && kite.state == .used {
                    try await updateKiteState(kiteId: kite.id, state: .free)
                }
            }
        }
}
