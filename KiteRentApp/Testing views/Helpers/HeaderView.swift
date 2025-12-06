//
//  HeaderView.swift
//  Testing views
//
//  Created by Filip on 15/11/2025.
//


import SwiftUI

struct HeaderView: View {
    var onWindTapped: (() -> Void)?

    var body: some View {
        HStack {
            Button {
                onWindTapped?()
            } label: {
                Image(systemName: "wind")
                    .font(.system(size: 22, weight: .semibold))
                    .padding(8)
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .shadow(radius: 2)
                    .foregroundStyle(.blue)
            }

            Spacer()

            ImageOrPlaceholder(name: "profile")
                .frame(width: 36, height: 36)
                .clipShape(Circle())
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }
}


#Preview {
    HeaderView()
}
