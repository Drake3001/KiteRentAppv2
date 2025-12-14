//
//  InstructorEditView.swift
//  KiteRentApp
//
//  Created by Filip on 12/12/2025.
//

import SwiftUI
import Foundation

struct InstructorEditView: View {
    @Environment(\.dismiss) var dismiss
    
    let originalInstructor: DBInstructor
    
    @State private var editableName: String
    @State private var editableSurname: String
    @State private var editablePhoneNumber: String
    @State private var editableState: InstructorState
    
    @State private var isSaving: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    init(instructor: DBInstructor) {
        self.originalInstructor = instructor
        _editableName = State(initialValue: instructor.name)
        _editableSurname = State(initialValue: instructor.surname)
        _editablePhoneNumber = State(initialValue: instructor.phoneNumber ?? "")
        _editableState = State(initialValue: instructor.state)
    }

    var body: some View {
            NavigationView {
                VStack(spacing: 0) {
                    Form {
                        Section(header: Text("Instructor Details")) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Name")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Enter name", text: $editableName)
                                    .autocorrectionDisabled()
                            }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Surname")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Enter surname", text: $editableSurname)
                                    .autocorrectionDisabled()
                            }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Phone Number")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Enter phone number", text: $editablePhoneNumber)
                                    .keyboardType(.numberPad)
                            }
                            
                            Picker("Instructor State", selection: $editableState) {
                                ForEach(InstructorState.allCases) { state in
                                    Text(state.rawValue.capitalized).tag(state)
                                }
                            }
                            .disabled(InstructorState.allCases.isEmpty)
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Edit \(originalInstructor.name) \(originalInstructor.surname)")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            Task { await saveChanges() }
                        }
                        .disabled(isSaving || !hasChanges || !isInputValid)
                    }
                }
                .overlay {
                    if isSaving {
                        ProgressView("Saving Changes...")
                            .padding()
                            .background(.ultraThickMaterial)
                            .cornerRadius(10)
                    }
                }
                .alert("Error", isPresented: $showAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(alertMessage)
                }
            }
        }
    
    // MARK: - Validation and Actions
    
    private var hasChanges: Bool {
        return editableName != originalInstructor.name ||
               editableSurname != originalInstructor.surname ||
               editablePhoneNumber != originalInstructor.phoneNumber ||
               editableState != originalInstructor.state
    }
    
    private var isInputValid: Bool {
        return !editableName.isEmpty &&
               !editableSurname.isEmpty &&
               !editablePhoneNumber.isEmpty
    }
    
    private func saveChanges() async {
        let instructorId = originalInstructor.instructorId
        
        guard isInputValid else {
            alertMessage = "Please ensure all fields are valid."
            showAlert = true
            return
        }
        
        isSaving = true
        
        var fieldsToUpdate: [String: Any] = [:]
        
        if editableName != originalInstructor.name {
            fieldsToUpdate["name"] = editableName
        }
        if editableSurname != originalInstructor.surname {
            fieldsToUpdate["surname"] = editableSurname
        }
        if editablePhoneNumber != originalInstructor.phoneNumber {
            fieldsToUpdate["kiteNumber"] = editablePhoneNumber
        }
        if editableState != originalInstructor.state {
            fieldsToUpdate["state"] = editableState.rawValue
        }
        
        guard !fieldsToUpdate.isEmpty else {
            isSaving = false
            dismiss()
            return
        }
        
        do {
            try await InstructorManager.shared.updateInstructorFields(instructorId: instructorId, fields: fieldsToUpdate)
            dismiss()
        } catch {
            print("Error updating kite: \(error)")
            alertMessage = "Failed to save changes: \(error.localizedDescription)"
            showAlert = true
        }
        
        isSaving = false
    }
}

#Preview {
    let mock = DBInstructor(instructorId: "123", name: "John", surname: "Kowalski", phoneNumber: "123456789", dateCreated: Date(), state: .active)
    InstructorEditView(instructor: mock)
}
