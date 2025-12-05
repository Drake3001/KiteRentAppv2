//
//  DBInstructor.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 23/11/2025.
//

import Foundation

struct DBInstructor: Codable, Identifiable {
    var id: String { instructorId }
    let instructorId: String
    let name: String
    let surname: String
    let phoneNumber: String?
    let dateCreated: Date?
    
    var shortName: String {
        "\(name) \(surname.prefix(1))"
    }
    
    enum CodingKeys: String, CodingKey {
        case instructorId = "instructor_id"
        case name = "name"
        case surname = "surname"
        case phoneNumber = "phone_number"
        case dateCreated = "date_created"
    }
}