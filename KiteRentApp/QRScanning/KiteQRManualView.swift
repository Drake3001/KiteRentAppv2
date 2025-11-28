//
//  KiteQRManualView.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 23/11/2025.
//

import SwiftUI

struct KiteQRManualView: View {
    @State private var inputKiteId: String = ""
    @State private var generatedQR: UIImage? = nil
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                TextField("Wpisz kite_id", text: $inputKiteId)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button("Pokaż QR") {
                    generateQR()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 10)
                .disabled(inputKiteId.isEmpty)
                
                Spacer()
                
                if let qr = generatedQR {
                    Image(uiImage: qr)
                        .interpolation(.none)
                        .resizable()
                        .frame(width: 250, height: 250)
                        .padding()
                    
                    Text("Kite ID: \(inputKiteId)")
                        .font(.headline)
                }
                
                Spacer()
            }
            .navigationTitle("Generuj QR dla Kite")
        }
    }
    
    func generateQR() {
        generatedQR = QRGenerator.generateQRCode(from: inputKiteId)
    }
}

#Preview {
    KiteQRManualView()
}
