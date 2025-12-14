//
//  AddInstructorView.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 23/11/2025.
//

import SwiftUI

struct AddInstructorView: View {
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var phoneNumber: String = ""
    @State private var isSaving = false
    @State private var message: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Instructor Info")) {
                    TextField("Imię", text: $name)
                    TextField("Nazwisko", text: $surname)
                    TextField("Phone number", text: $phoneNumber)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                Button(action: saveInstructor) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text("Dodaj Instruktora")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .disabled(name.isEmpty)
                
                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(.blue)
                        .padding(.top, 10)
                }
            }
            .navigationTitle("Dodaj Instruktora")
        }
    }
    
    func saveInstructor() {
        isSaving = true
        message = ""
        
        Task {
            let newInstructor = DBInstructor(
                instructorId: UUID().uuidString,
                name: name,
                surname: surname,
                phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
                dateCreated: Date(),
                state: .active
            )
            
            do {
                try await InstructorManager.shared.createNewInstructor(instructor: newInstructor)
                message = "Instruktor zapisany poprawnie!"
                clearForm()
            } catch {
                message = "Błąd zapisu: \(error.localizedDescription)"
            }
            
            isSaving = false
        }
    }
    
    func clearForm() {
        name = ""
        surname = ""
        phoneNumber = ""
    }
}


#Preview {
    AddInstructorView()
}
