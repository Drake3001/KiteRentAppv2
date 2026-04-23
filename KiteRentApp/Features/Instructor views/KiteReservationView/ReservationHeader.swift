//
//  ReservationHeader.swift
//  KiteRentApp
//
//  Created by Filip on 29/11/2025.
//

import SwiftUI

struct ReservationHeader: View {
    let kite: DBKite
    var mediaRefreshToken: UUID = UUID()
    var mediaRepository: MediaRepositoryProtocol = MediaRepository.shared

    var body: some View {
        VStack(spacing: 8) {
            MediaImageView(
                ownerType: .kite,
                ownerId: kite.id ?? "",
                mediaRepository: mediaRepository,
                contentMode: .fit,
                refreshToken: mediaRefreshToken
            )
            .frame(width: 120, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            Text("Rezerwacja latawca")
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(kite.name)
                .font(.subheadline)
                .foregroundColor(Color(.secondaryLabel))
        }
    }
}

#Preview {
    ReservationHeader(
        kite: DBKite(id: "demo", name: "Demo", imageName: "demo", state: .free, brand: "demo", kiteModel: "demo", size: "9", dateCreated: nil),
        mediaRefreshToken: UUID()
    )
    
}
