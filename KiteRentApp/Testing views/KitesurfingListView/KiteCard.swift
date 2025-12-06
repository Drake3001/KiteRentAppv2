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
                if kite.state == .used, let instructor = instructor {
                    Text(instructor.shortName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                } else if kite.state == .serviced {
                    Text("Serviced")
                        .font(.caption)
                        .foregroundColor(.red)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }
                
                Spacer(minLength: 0)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 4)

            if kite.state != .free {
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.80))

                RoundedRectangle(cornerRadius: 18)
                    .fill(tintColor)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct KiteCard_Previews: PreviewProvider {
    static var previews: some View {
        KiteCard(kite: DBKite(id: "demo", name: "Demo", imageName: "demo", state: .free, brand: "demo", kiteModel: "demo", size: "9", dateCreated: nil))
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
