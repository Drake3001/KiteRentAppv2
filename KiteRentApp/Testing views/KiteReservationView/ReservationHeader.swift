//
//  ReservationHeader.swift
//  KiteRentApp
//
//  Created by Filip on 29/11/2025.
//

import SwiftUI

struct ReservationHeader: View {
    let kite: DBKite
    
    var body: some View {
        VStack(spacing: 4) {
            Text("Rezerwacja latawca")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(kite.name)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}
