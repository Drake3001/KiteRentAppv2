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
    @State private var brand: String = ""
    @State private var kiteModel: String = ""
    @State private var size: String = ""
    @State private var isSaving = false
    @State private var message: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kite Info")) {
                    TextField("Kite ID", text: $id)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    TextField("Nazwa", text: $name)
                        .autocorrectionDisabled(true)
                    TextField("URL zdjęcia", text: $imageName)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled(true)
                    
                    Picker("Status", selection: $state) {
                        Text("Wolny").tag(KiteState.free)
                        Text("Zajęty").tag(KiteState.used)
                        Text("Niedostępny").tag(KiteState.serviced)
                    }
                }
                
                Section(header: Text("Specyfikacja")) {
                    TextField("Marka", text: $brand)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    TextField("Model", text: $kiteModel)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    TextField("Rozmiar (np. 9, 12)", text: $size)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.numbersAndPunctuation)
                        .autocorrectionDisabled(true)
                }
                
                Button(action: saveKite) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Dodaj Kite")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .disabled(isSaveDisabled)
                
                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(.blue)
                        .padding(.top, 10)
                }
            }
            .navigationTitle("Dodaj Kite")
        }
    }
    
    private var isSaveDisabled: Bool {
        id.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        kiteModel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        size.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func saveKite() {
        isSaving = true
        message = ""
        
        Task {
            let newKite = DBKite(
                id: id.trimmingCharacters(in: .whitespacesAndNewlines),
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                imageName: imageName.trimmingCharacters(in: .whitespacesAndNewlines),
                state: state,
                brand: brand.trimmingCharacters(in: .whitespacesAndNewlines),
                kiteModel: kiteModel.trimmingCharacters(in: .whitespacesAndNewlines),
                size: size.trimmingCharacters(in: .whitespacesAndNewlines),
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
        brand = ""
        kiteModel = ""
        size = ""
    }
}

#Preview {
    AddKiteView()
}
