//
//  AddKiteView.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 23/11/2025.
//

import SwiftUI

struct AddKiteView: View {
    @State private var id: String = ""
    @State private var name: String = ""
    @State private var imageName: String = ""
    @State private var state: KiteState = .free
    @State private var isSaving = false
    @State private var message: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kite Info")) {
                    TextField("Kite ID", text: $id)
                    TextField("Nazwa", text: $name)
                    TextField("URL zdjęcia", text: $imageName)
                    
                    Picker("Status", selection: $state) {
                        Text("Wolny").tag(KiteState.free)
                        Text("Zajęty").tag(KiteState.used)
                        Text("Niedostępny").tag(KiteState.serviced)
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
                .disabled(id.isEmpty || name.isEmpty)
                
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
                id: id,
                name: name,
                imageName: imageName,
                state: state,
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
        id = ""
        name = ""
        imageName = ""
        state = .free
    }
}

#Preview {
    AddKiteView()
}
