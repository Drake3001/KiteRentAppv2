//
//  KiteListView.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 23/11/2025.
//

import SwiftUI

struct KiteListView: View {
    @State private var text = "Ładowanie..."

    var body: some View {
        ScrollView {
            Text(text)
                .padding()
        }
        .task {
            await loadKites()
        }
    }
    
    func loadKites() async {
        do {
            let kites = try await KiteManager.shared.getAllKites()
            
            text = kites.map { kite in
                """
                ID: \(kite.kiteId)
                Nazwa: \(kite.name)
                Status: \(kite.status.rawValue)
                Zdjęcie: \(kite.zdjecie)
                
                """
            }.joined(separator: "---------------------\n")
            
        } catch {
            text = "Błąd: \(error.localizedDescription)"
        }
    }
}

#Preview {
    KiteListView()
}
