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
            .fontWeight(.medium)
            .padding(.vertical, 5)
            .padding(.horizontal, 10)
            .background(backgroundColor)
            .cornerRadius(12)
    }
}

#Preview {
    TagView(text: "Demo", backgroundColor: .green)
}
