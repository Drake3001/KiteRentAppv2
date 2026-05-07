import SwiftUI
import Foundation
import PhotosUI
import UIKit

struct KiteEditView: View {
    @Environment(\.dismiss) var dismiss

    @StateObject private var viewModel: AdminKiteEditViewModel
    @State private var photoPickerItem: PhotosPickerItem?

    init(kite: DBKite) {
        _viewModel = StateObject(wrappedValue: AdminKiteEditViewModel(kite: kite))
    }

    var body: some View {
        ZStack {
            AdminGlassBackground()

            ScrollView {
                VStack(spacing: 22) {
                    GlassEditorSection(title: "Kite details") {
                        VStack(spacing: 14) {
                            GlassTextField(title: "Name", placeholder: "Enter name", text: $viewModel.editableName)
                            GlassTextField(title: "Brand", placeholder: "Enter brand", text: $viewModel.editableBrand)
                            GlassTextField(title: "Model", placeholder: "Enter model", text: $viewModel.editableModel)
                            GlassTextField(
                                title: "Size (meters)",
                                placeholder: "e.g. 9, 12",
                                text: $viewModel.editableSize,
                                keyboardType: .decimalPad
                            )

                            HStack {
                                Text("Kite state")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Picker("Kite State", selection: $viewModel.editableState) {
                                    ForEach(KiteState.allCases) { state in
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

                    GlassEditorSection(title: "Photo") {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 12) {
                                MediaPicker(
                                    selection: $photoPickerItem,
                                    label: "Choose photo",
                                    onPicked: { data in
                                        viewModel.setPickedImageData(data)
                                    }
                                )
                                .buttonStyle(.bordered)

                                if viewModel.displayImageData != nil {
                                    Button("Remove", role: .destructive) {
                                        viewModel.clearImage()
                                    }
                                    .buttonStyle(.bordered)
                                }
                                Spacer(minLength: 0)
                            }

                            if let data = viewModel.displayImageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 250)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                                    }
                            } else {
                                Text("No photo yet. Choose an image to store locally in SwiftData.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
            }
            .scrollIndicators(.hidden)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationTitle("Edit \(viewModel.originalKite.name)")
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
                .disabled(viewModel.isSaving || !viewModel.hasAnyChanges || !viewModel.isInputValid)
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
        KiteEditView(
            kite: DBKite(id: "123", name: "North reach 9", imageName: "reach9", state: .free, brand: "North", kiteModel: "Reach", size: "9", dateCreated: Date())
        )
    }
}
