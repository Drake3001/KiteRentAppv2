//
//  Kite.swift
//  Testing views
//
//  Created by Filip on 15/11/2025.
//

import Foundation

struct Kite: Identifiable, Codable {
    var id: Int
    var name: String
    var imageName: String
    var state: KiteState
    var currentUser: String?
}

/*enum KiteState: String, Codable {
    case free
    case used
    case serviced
}*/

