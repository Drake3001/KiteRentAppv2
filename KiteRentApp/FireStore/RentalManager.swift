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
        try await rentalDocument(rentalId: rental.rentalId).setData(from: rental, merge: false)
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
        let snapshot = try await rentalCollection
            .whereField("end_time", isGreaterThan: Date())
            .getDocuments()
        
        return try snapshot.documents.map { document in
            try document.data(as: DBRental.self)
        }
    }
    
    func getRentalsForInstructor(instructorId: String) async throws -> [DBRental] {
        let snapshot = try await rentalCollection
            .whereField("instructor_id", isEqualTo: instructorId)
            .getDocuments()
        
        return try snapshot.documents.map { try $0.data(as: DBRental.self) }
    }
    /// Rentals for this kite whose **start** falls on the same local calendar day as `dayContaining`.
    /// Matches day-based reservation UI; avoids loading the kite’s full rental history.
    private func getRentalsForKite(_ kiteId: String, startingOnCalendarDayContaining dayContaining: Date, calendar: Calendar = .current) async throws -> [DBRental] {
        let startOfDay = calendar.startOfDay(for: dayContaining)
        guard let startOfNextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        let snapshot = try await rentalCollection
            .whereField("kite_id", isEqualTo: kiteId)
            .whereField("start_time", isGreaterThanOrEqualTo: startOfDay)
            .whereField("start_time", isLessThan: startOfNextDay)
            .getDocuments()
        
        return try snapshot.documents.map { try $0.data(as: DBRental.self) }
    }
    
    func hasOverlappingRental(kiteId: String, start: Date, end: Date) async throws -> Bool {
        let existing = try await getRentalsForKite(kiteId, startingOnCalendarDayContaining: start)
        return RentalOverlap.hasOverlap(in: existing, start: start, end: end)
    }
    
    func updateRentalFields(rentalId: String, fields: [String: Any]) async throws {
        try await rentalDocument(rentalId: rentalId).updateData(fields)
    }
    
    func updateRental(rental: DBRental) async throws {
        try await rentalDocument(rentalId: rental.rentalId).setData(from: rental, merge: true)
    }
    
    func deleteRental(rentalId: String) async throws {
        try await rentalDocument(rentalId: rentalId).delete()
    }
}
