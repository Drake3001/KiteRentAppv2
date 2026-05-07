//
//  FilterRowView.swift
//  Testing views
//
//  Created by Filip on 15/11/2025.
//

import SwiftUI

struct FilterRowView: View {
    let numberOfElements: Int
    
    var onSortTapped: (() -> Void)? = nil
    var isAscending: Bool = false

    var body: some View {
        HStack {
            Button(action: { onSortTapped?() }) {
                HStack(spacing: 6) {
                    Text("Sort")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Image(systemName: isAscending ? "arrow.up" : "arrow.down")
                        .font(.caption)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                }
            }
            Spacer()
            Text("\(numberOfElements) results")
                .foregroundColor(Color(.secondaryLabel))
                .font(.subheadline)
        }
        .padding(.horizontal)
        .padding(.top, 6)
    }
}

#Preview {
    FilterRowView(numberOfElements: 0)
}
