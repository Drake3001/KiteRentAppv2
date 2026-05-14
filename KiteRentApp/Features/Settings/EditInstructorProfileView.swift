//
//  EditInstructorProfileView.swift
//  KiteRentApp
//

import PhotosUI
import SwiftUI
import UIKit

struct EditInstructorProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EditInstructorProfileViewModel()

    var onProfileSaved: () -> Void

    @State private var photoPickerItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section("Photo") {
                        HStack(spacing: 12) {
                            if let data = viewModel.displayImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 72, height: 72)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color(.systemGray5))
                                    .frame(width: 72, height: 72)
                                    .overlay {
                                        Image(systemName: "person.fill")
                                            .foregroundStyle(.secondary)
                                    }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                MediaPicker(
                                    selection: $photoPickerItem,
                                    label: "Choose Photo",
                                    onPicked: { viewModel.applyPickedMedia($0) }
                                )

                                if viewModel.displayImageData != nil {
                                    Button("Remove Photo", role: .destructive) {
                                        viewModel.clearImage()
                                    }
                                }
                            }
                        }
                    }

                    Section("Details") {
                        TextField("Name", text: $viewModel.editableName)
                        TextField("Surname", text: $viewModel.editableSurname)
                        TextField("Phone number (optional)", text: $viewModel.editablePhoneNumber)
                            .keyboardType(.phonePad)
                    }
                }
                .disabled(viewModel.isLoadingInitial)

                if viewModel.isLoadingInitial {
                    ProgressView("Loading…")
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.save {
                                onProfileSaved()
                                dismiss()
                            }
                        }
                    }
                    .disabled(
                        viewModel.isSaving ||
                            !viewModel.isInputValid ||
                            !viewModel.hasAnyChanges ||
                            viewModel.isLoadingInitial
                    )
                }
            }
            .task {
                await viewModel.loadInitial()
            }
            .overlay {
                if viewModel.isSaving {
                    ProgressView("Saving…")
                        .padding(22)
                        .background(.ultraThickMaterial, in: RoundedRectangle(cornerRadius: 16))
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
    EditInstructorProfileView(onProfileSaved: {})
}
