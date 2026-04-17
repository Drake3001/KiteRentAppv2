//
//  HeaderView.swift
//  Testing views
//
//  Created by Filip on 15/11/2025.
//


import SwiftUI

struct HeaderView: View {
    var onWindTapped: (() -> Void)?
    var onLoginTapped: (() -> Void)?
    
    var body: some View {
        HStack {
            Button {
                onWindTapped?()
            } label: {
                Image(systemName: "wind")
                    .font(.system(size: 22, weight: .semibold))
                    .padding(8)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Circle())
                    .shadow(radius: 2)
                    .foregroundStyle(.blue)
            }

            Spacer()
            
            Button{
                onLoginTapped?()
            } label: {
                let uiImage = UIImage(named: "loginIcon")!
                Image(uiImage: uiImage)
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 22, height: 22)
                    .padding(8)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Circle())
                    .shadow(radius: 2)
                    .foregroundStyle(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }
}


#Preview {
    HeaderView()
}
