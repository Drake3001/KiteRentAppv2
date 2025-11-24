//
//  FilterButton.swift
//  Testing views
//
//  Created by Filip on 15/11/2025.
//

import SwiftUI

struct FilterButton: View {
    let title: String
    
    var body: some View {
        HStack(spacing: 6) {
            Text(title).font(.subheadline)
            Image(systemName: "chevron.down").font(.caption)
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

struct FilterButton_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FilterButton(title: "Filter")
                .previewLayout(.sizeThatFits)
                .padding()
            
            FilterButton(title: "Sort")
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
                .padding()
        }
    }
}

