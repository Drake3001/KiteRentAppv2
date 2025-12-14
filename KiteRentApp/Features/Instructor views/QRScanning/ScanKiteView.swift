import SwiftUI

struct ScanKiteView: View {
    @State private var showScanner = false
    @State private var scannedKiteId: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Button("Skanuj QR / Otwórz kamerę") {
                showScanner = true
            }
            .buttonStyle(.borderedProminent)

            if !scannedKiteId.isEmpty {
                Text("Zeskanowano kite_id:")
                Text(scannedKiteId)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.blue)
            }
        }
        .sheet(isPresented: $showScanner) {
            QRScannerView(onFound: { result in
                // result to string z QR
                scannedKiteId = result
                showScanner = false
                // możma niby zrobić -> fetch kite z Firestore tutaj
                // Task { let kite = try await KiteManager.shared.getKite(kiteId: result) ... }
            }, onCancel: {
                showScanner = false
            })
        }
    }
}
