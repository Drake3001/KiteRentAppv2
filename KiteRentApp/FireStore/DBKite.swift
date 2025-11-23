//
//  DBKite.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 23/11/2025.
//

import Foundation

enum KiteStatus: String, Codable {
    case wolny
    case zajety
    case niedostepny
}

struct DBKite: Codable {
    let kiteId: String
    let name: String
    let zdjecie: String
    let status: KiteStatus
    let dateCreated: Date?
    
    enum CodingKeys: String, CodingKey {
        case kiteId = "kite_id"
        case name = "name"
        case zdjecie = "zdjecie"
        case status = "status"
        case dateCreated = "date_created"
    }
}

