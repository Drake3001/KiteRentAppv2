//
//  FilterRowView.swift
//  Testing views
//
//  Created by Filip on 15/11/2025.
//

import SwiftUI

struct FilterRowAdminView: View {
    @Binding var selectedDate: Date?
    let numberOfElements: Int
    
    var onSortTapped: (() -> Void)? = nil
    var isAscending: Bool = false

    var body: some View {
        HStack {
            Button(action: { onSortTapped?() }) {
                HStack(spacing: 6) {
                    Text("Sort")
                        .font(.subheadline)
                    Image(systemName: isAscending ? "arrow.up" : "arrow.down")
                        .font(.caption)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            Spacer(minLength: 15)
            
            DateWheelPicker(selectedDate: $selectedDate)
            
            Spacer(minLength: 15)
            
            Text("\(numberOfElements) results")
                .foregroundColor(.gray)
                .font(.subheadline)
        }
        .padding(.horizontal)
        .padding(.top, 6)
    }
}

#Preview {
    FilterRowAdminView(selectedDate: .constant(Date()), numberOfElements: 0)
}
