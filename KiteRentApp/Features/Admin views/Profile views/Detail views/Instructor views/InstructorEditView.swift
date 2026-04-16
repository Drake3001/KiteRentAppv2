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
    
    @StateObject private var viewModel: AdminInstructorEditViewModel
    
    init(instructor: DBInstructor) {
        _viewModel = StateObject(wrappedValue: AdminInstructorEditViewModel(instructor: instructor))
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
                                TextField("Enter name", text: $viewModel.editableName)
                                    .autocorrectionDisabled()
                            }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Surname")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Enter surname", text: $viewModel.editableSurname)
                                    .autocorrectionDisabled()
                            }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Phone Number")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Enter phone number", text: $viewModel.editablePhoneNumber)
                                    .keyboardType(.numberPad)
                            }
                            
                            Picker("Instructor State", selection: $viewModel.editableState) {
                                ForEach(InstructorState.allCases) { state in
                                    Text(state.rawValue.capitalized).tag(state)
                                }
                            }
                            .disabled(InstructorState.allCases.isEmpty)
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Edit \(viewModel.originalInstructor.name) \(viewModel.originalInstructor.surname)")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            Task { await viewModel.save(onSuccess: { dismiss() }) }
                        }
                        .disabled(viewModel.isSaving || !viewModel.hasChanges || !viewModel.isInputValid)
                    }
                }
                .overlay {
                    if viewModel.isSaving {
                        ProgressView("Saving Changes...")
                            .padding()
                            .background(.ultraThickMaterial)
                            .cornerRadius(10)
                    }
                }
                .alert("Error", isPresented: $viewModel.showErrorAlert) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text(viewModel.errorMessage)
                }
            }
        }
}

#Preview {
    let mock = DBInstructor(instructorId: "123", name: "John", surname: "Kowalski", phoneNumber: "123456789", dateCreated: Date(), state: .active)
    InstructorEditView(instructor: mock)
}
