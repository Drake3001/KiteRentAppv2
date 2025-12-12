//
//  DBKite.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 23/11/2025.
//

import Foundation
import FirebaseFirestore


struct DBKite: Identifiable, Codable {
//    var id: String
    @DocumentID var id: String?
    var name: String
    var imageName: String
    var state: KiteState
    var brand: String
    var kiteModel: String
    var size: String
    var dateCreated: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case imageName = "image_name"
        case state = "state"
        case brand = "brand"
        case kiteModel = "kite_model"
        case size = "size"
        case dateCreated = "date_created"
    }
    
//    init(from document: DocumentSnapshot) throws {
//        let data = try document.data(as: DBKite.self)
//        self = data
//        self.id = document.documentID
//    }
    
}

enum KiteState: String, Codable, Comparable, CaseIterable, Identifiable {
    case free
    case used
    case serviced

    var id: String {
        self.rawValue
    }
    
    static func < (lhs: KiteState, rhs: KiteState) -> Bool {
        let order: [KiteState] = [.free, .used, .serviced]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}
