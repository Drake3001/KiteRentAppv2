//
//  AddKiteView.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 23/11/2025.
//

import SwiftUI

struct AddKiteView: View {
    @State private var kiteId: String = ""
    @State private var name: String = ""
    @State private var zdjecie: String = ""
    @State private var status: KiteStatus = .wolny
    @State private var isSaving = false
    @State private var message: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kite Info")) {
                    TextField("Kite ID", text: $kiteId)
                    TextField("Nazwa", text: $name)
                    TextField("URL zdjęcia", text: $zdjecie)
                    
                    Picker("Status", selection: $status) {
                        Text("Wolny").tag(KiteStatus.wolny)
                        Text("Zajęty").tag(KiteStatus.zajety)
                        Text("Niedostępny").tag(KiteStatus.niedostepny)
                    }
                }
                
                Button(action: saveKite) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Dodaj Kite")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .disabled(kiteId.isEmpty || name.isEmpty)
                
                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(.blue)
                        .padding(.top, 10)
                }
            }
            .navigationTitle("Dodaj Kite")
        }
    }
    
    func saveKite() {
        isSaving = true
        message = ""
        
        Task {
            let newKite = DBKite(
                kiteId: kiteId,
                name: name,
                zdjecie: zdjecie,
                status: status,
                dateCreated: Date()
            )
            
            do {
                try await KiteManager.shared.createNewKite(kite: newKite)
                message = "Kite zapisany poprawnie!"
                clearForm()
            } catch {
                message = "Błąd zapisu: \(error.localizedDescription)"
            }
            
            isSaving = false
        }
    }
    
    func clearForm() {
        kiteId = ""
        name = ""
        zdjecie = ""
        status = .wolny
    }
}
