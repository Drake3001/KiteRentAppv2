//
//  DBUser.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 23/11/2025.
//

import Foundation

struct DBUser: Codable {
    let userId: String
    let email: String?
    let dateCreated: Date?
    let role: UserRole
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email = "email"
        case dateCreated = "date_created"
        case role = "role"
    }
}

enum UserRole: String, Codable, Hashable {
    case instructor
    case admin
}
