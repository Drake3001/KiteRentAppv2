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
        ZStack {
            AdminGlassBackground()

            ScrollView {
                VStack(spacing: 22) {
                    GlassEditorSection(title: "Instructor details") {
                        VStack(spacing: 14) {
                            GlassTextField(title: "Name", placeholder: "Enter name", text: $viewModel.editableName)
                            GlassTextField(title: "Surname", placeholder: "Enter surname", text: $viewModel.editableSurname)
                            GlassTextField(
                                title: "Phone number",
                                placeholder: "Enter phone number",
                                text: $viewModel.editablePhoneNumber,
                                keyboardType: .numberPad
                            )

                            HStack {
                                Text("Instructor state")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Picker("Instructor State", selection: $viewModel.editableState) {
                                    ForEach(InstructorState.allCases) { state in
                                        Text(state.rawValue.capitalized).tag(state)
                                    }
                                }
                                .labelsHidden()
                                .pickerStyle(.menu)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(.ultraThinMaterial)
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Edit \(viewModel.originalInstructor.name) \(viewModel.originalInstructor.surname)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    Task { await viewModel.save(onSuccess: { dismiss() }) }
                }
                .disabled(viewModel.isSaving || !viewModel.hasChanges || !viewModel.isInputValid)
            }
        }
        .overlay {
            if viewModel.isSaving {
                ProgressView("Saving Changes...")
                    .padding(22)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThickMaterial)
                    }
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    }
                    .shadow(color: .black.opacity(0.2), radius: 24, y: 12)
            }
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage)
        }
    }
}

#Preview {
    NavigationStack {
        InstructorEditView(
            instructor: DBInstructor(instructorId: "123", name: "John", surname: "Kowalski", phoneNumber: "123456789", dateCreated: Date(), state: .active)
        )
    }
}
