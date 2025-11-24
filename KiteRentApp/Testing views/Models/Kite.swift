//
//  Kite.swift
//  Testing views
//
//  Created by Filip on 15/11/2025.
//

import Foundation

struct Kite: Identifiable, Decodable {
    var id: Int
    var name: String
    var imageName: String
    var state: KiteState
    var currentUser: String?
}

enum KiteState: String, Decodable {
    case free
    case used
    case serviced
}

