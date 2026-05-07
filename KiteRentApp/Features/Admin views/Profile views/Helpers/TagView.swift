//
//  TagView.swift
//  KiteRentApp
//
//  Created by Filip on 11/12/2025.
//

import SwiftUI

struct TagView: View {
    let text: String
    let backgroundColor: Color
    
    var body: some View {
        Text(text)
            .font(.subheadline)
            .fontWeight(.semibold)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
            .background {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay {
                        Capsule()
                            .fill(backgroundColor.opacity(0.22))
                    }
            }
            .overlay {
                Capsule()
                    .strokeBorder(backgroundColor.opacity(0.5), lineWidth: 1)
            }
    }
}

#Preview {
    TagView(text: "Demo", backgroundColor: .green)
}
