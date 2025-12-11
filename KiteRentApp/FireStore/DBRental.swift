//
//  DBRental.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 23/11/2025.
//

import Foundation

struct DBRental: Codable, Identifiable {
    let rentalId: String
    let kiteId: String
    let instructorId: String
    let startTime: Date
    let endTime: Date
    
    var id: String {rentalId}
    
    enum CodingKeys: String, CodingKey {
        case rentalId = "rental_id"
        case kiteId = "kite_id"
        case instructorId = "instructor_id"
        case startTime = "start_time"
        case endTime = "end_time"
    }
}
