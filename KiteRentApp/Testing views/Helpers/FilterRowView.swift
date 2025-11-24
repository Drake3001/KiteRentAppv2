//
//  FilterRowView.swift
//  Testing views
//
//  Created by Filip on 15/11/2025.
//


import SwiftUI

struct FilterRowView: View {
    let numberOfKites = kites.count
    
    var body: some View {
        HStack {
            FilterButton(title: "Filter")
                
            FilterButton(title: "Sort")
            
            Spacer()
            

            
            Text("\(numberOfKites) results")
                .foregroundColor(.gray)
                .font(.subheadline)
        }
        .padding(.horizontal)
        .padding(.top, 6)
    }
}

#Preview {
    FilterRowView()
}
