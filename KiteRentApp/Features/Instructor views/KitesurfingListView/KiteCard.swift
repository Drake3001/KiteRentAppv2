//
//  KiteCard.swift
//  Testing views
//
//  Created by Filip on 15/11/2025.
//

import SwiftUI

struct KiteCard: View {
    var kite: DBKite
    var instructor: DBInstructor? = nil
    var mediaRefreshToken: UUID
    var mediaRepository: MediaRepositoryProtocol = MediaRepository.shared
    
    var tintColor: Color {
        switch kite.state {
        case .free:
            return Color.clear
        case .used:
            return Color.black.opacity(0.1)
        case .serviced:
            return Color.red.opacity(0.2)
        }
    }
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                MediaImageView(
                    ownerType: .kite,
                    ownerId: kite.id ?? "",
                    mediaRepository: mediaRepository,
                    contentMode: .fit,
                    refreshToken: mediaRefreshToken
                )
                .scaledToFit()
                .frame(height: 140)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Rectangle()
                    .fill(Color(.separator))
                    .frame(height: 0.5)
                
                Text(kite.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Spacer(minLength: 0)
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.primary.opacity(0.08), radius: 2, y: 4)
            
            if kite.state != .free {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color(.systemBackground).opacity(0.80))
                
                RoundedRectangle(cornerRadius: 18)
                    .fill(tintColor)
            }
            
            if kite.state == .used, let instructor = instructor {
                HStack(spacing: 12) {
                    Image(systemName: "person.fill")
                    Text(instructor.shortName)
                        .opacity(1)
                }
                .font(.body)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color(.systemBackground))
                        .opacity(0.7)
                        .shadow(color: Color.primary.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
            else if kite.state == .serviced {
                Text("Serviced")
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color(.systemBackground))
                            .opacity(0.7)
                            .shadow(color: Color.primary.opacity(0.1), radius: 4, x: 0, y: 2)
                    )
            }
        }
        .frame(maxWidth: .infinity)

    }
}

struct KiteCard_Previews: PreviewProvider {
    static var previews: some View {
        KiteCard(
            kite: DBKite(id: "demo", name: "Demo", imageName: "demo", state: .free, brand: "demo", kiteModel: "demo", size: "9", dateCreated: nil),
            mediaRefreshToken: UUID()
        )
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
