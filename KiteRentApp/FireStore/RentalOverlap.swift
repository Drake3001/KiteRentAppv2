//
//  RentalOverlap.swift
//  KiteRentApp
//

import Foundation

/// In-memory rental interval overlap check (no Firestore).
enum RentalOverlap {
    /// Two intervals overlap when each one starts before the other ends.
    static func hasOverlap(in existing: [DBRental], start: Date, end: Date) -> Bool {
        existing.contains { rental in
            rental.startTime < end && rental.endTime > start
        }
    }
}
