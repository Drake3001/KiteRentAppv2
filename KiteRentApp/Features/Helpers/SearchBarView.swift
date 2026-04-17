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
        .padding()
        .background(Color(.tertiarySystemFill))
        .cornerRadius(25)
        .padding(.horizontal)
    }
}

#Preview {
    SearchBarView(text: .constant(""))
}
