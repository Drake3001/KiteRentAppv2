//
//  KiteCard.swift
//  Testing views
//
//  Created by Filip on 15/11/2025.
//


import SwiftUI

struct KiteCard: View {
    var kite: Kite
    
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
            // Base card
            VStack(alignment: .leading, spacing: 8) {
                ImageOrPlaceholder(name: kite.imageName)
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
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 4)
            
            
            if (kite.state != .free) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.80))
                
                
                RoundedRectangle(cornerRadius: 18)
                    .fill(tintColor)
            }
            
            
            // Overlayed user name
            if kite.state == .used, let user = kite.currentUser {
                HStack(spacing: 12) {
                    Image(systemName: "person.fill")
                    Text(user)
                        .opacity(1) // ensures text is fully opaque
                }
                .font(.footnote)
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(Color.white)
                        .opacity(0.7) // only the background is semi-transparent
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct KiteCard_Previews: PreviewProvider {
    static var previews: some View {
        KiteCard(kite: kites[3])
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
