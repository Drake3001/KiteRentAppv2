//
//  SearchBarView.swift
//  Testing views
//
//  Created by Filip on 15/11/2025.
//


import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass").foregroundColor(Color(.secondaryLabel))
            
            TextField("Search", text: $text)
                .submitLabel(.search)
            
            Image(systemName: "mic.fill").foregroundColor(Color(.secondaryLabel))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(.thinMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.35),
                            Color.white.opacity(0.08),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        }
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }
}

#Preview {
    SearchBarView(text: .constant(""))
}
