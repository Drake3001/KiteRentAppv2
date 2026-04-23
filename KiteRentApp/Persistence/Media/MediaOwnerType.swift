//
//  MediaOwnerType.swift
//  KiteRentApp
//

import Foundation

/// Identifies which domain entity owns a stored media row in SwiftData.
enum MediaOwnerType: String, Codable, CaseIterable, Sendable {
    case kite
    case userProfile
}
