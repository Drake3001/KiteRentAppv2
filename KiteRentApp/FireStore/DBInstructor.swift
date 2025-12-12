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
    var state: InstructorState
    
    var shortName: String {
        "\(name) \(surname.prefix(1))"
    }
    
    enum CodingKeys: String, CodingKey {
        case instructorId = "instructor_id"
        case name = "name"
        case surname = "surname"
        case phoneNumber = "phone_number"
        case dateCreated = "date_created"
        case state = "state"
    }
}

enum InstructorState: String, Codable, Comparable, CaseIterable, Identifiable {
    case active
    case inactive

    var id: String {
        self.rawValue
    }
    
    static func < (lhs: InstructorState, rhs: InstructorState) -> Bool {
        let order: [InstructorState] = [.active, .inactive]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}
