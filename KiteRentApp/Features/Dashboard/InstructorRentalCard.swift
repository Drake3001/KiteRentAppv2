//
//  InstructorRentalCard.swift
//  KiteRentApp
//
//  Created by Vilstig on 07/05/2026.
//
import SwiftUI

struct InstructorRentalCard: View {
    let rental: InstructorRental
    let onEdit: () -> Void
    let onEnd: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    var mediaRefreshToken: UUID? = nil
    var mediaRepository: MediaRepositoryProtocol = MediaRepository.shared
    
    private var isActive: Bool {
        rental.endTime > Date()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            MediaImageView(
                ownerType: .kite,
                ownerId: rental.kiteId,
                mediaRepository: mediaRepository,
                contentMode: .fit,
                refreshToken: mediaRefreshToken,
                useThumbnail: true
            )
            .scaledToFit()
            .frame(maxWidth: .infinity, alignment: .center)
            .frame(height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            
            
            Rectangle()
                .fill(Color(.separator))
                .frame(height: 0.5)
            
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(rental.kiteName)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    Text("\(isActive ? "Ends at" : "Ended at"): \(rental.endTime.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits)))")
                        .font(.caption)
                        .foregroundStyle(Color(.secondaryLabel))
                        .lineLimit(1)
                }
                
                Spacer(minLength: 8)
                
                HStack(spacing: 10) {
                    Button(action: onEdit) {
                        Text("Edit")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                    }
                    .glassEffect()
                    .disabled(!isActive)
                    .opacity(isActive ? 1 : 0.45)
                    
                    Button(action: onEnd) {
                        Text("End")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.red)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                    }
                    .glassEffect()
                    .disabled(!isActive)
                    .opacity(isActive ? 1 : 0.45)
                }
            }
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.primary.opacity(colorScheme == .dark ? 0.15 : 0.08), radius: 2, y: 4)
        .frame(maxWidth: .infinity)
    }
}
