//
//  DocumentReference+AsyncEncodable.swift
//  KiteRentApp
//
//  Firebase's Encodable `setData(from:merge:)` only surfaces server errors via a completion
//  handler. This wraps `try await setData(_:merge:)` so permission and network failures throw.
//

import Foundation
import FirebaseFirestore

extension DocumentReference {
    /// Encodes `value` and writes it, awaiting server acknowledgment (or a terminal error).
    func setData<T: Encodable>(from value: T, merge: Bool = false) async throws {
        let encoder = Firestore.Encoder()
        let data = try encoder.encode(value)
        try await setData(data, merge: merge)
    }
}
