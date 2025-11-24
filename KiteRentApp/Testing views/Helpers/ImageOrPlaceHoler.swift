//
//  ImageOrPlaceHoler.swift
//  Testing views
//
//  Created by Filip on 15/11/2025.
//

import SwiftUI

struct ImageOrPlaceholder: View {
    let name: String
    
    var body: some View {
        if let uiImage = UIImage(named: name) {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .padding(20)
                .foregroundColor(.gray)
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct ImageOrPlaceholder_Previews: PreviewProvider {
    static var previews: some View {
        ImageOrPlaceholder(name: "nonexistent")
            .frame(width: 200, height: 200)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}

