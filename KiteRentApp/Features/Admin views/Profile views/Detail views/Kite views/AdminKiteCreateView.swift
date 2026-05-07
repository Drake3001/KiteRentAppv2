import SwiftUI
import Foundation
import PhotosUI
import UIKit

struct AdminKiteCreateView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = AdminKiteCreateViewModel()
    @State private var photoPickerItem: PhotosPickerItem?

    var body: some View {
        ZStack {
            AdminGlassBackground()

            ScrollView {
                VStack(spacing: 22) {
                    GlassEditorSection(title: "Kite details") {
                        VStack(spacing: 14) {
                            GlassTextField(title: "Name", placeholder: "Enter name", text: $viewModel.name)
                            GlassTextField(title: "Brand", placeholder: "Enter brand", text: $viewModel.brand)
                            GlassTextField(title: "Model", placeholder: "Enter model", text: $viewModel.model)
                            GlassTextField(
                                title: "Size (meters)",
                                placeholder: "e.g. 9, 12",
                                text: $viewModel.size,
                                keyboardType: .decimalPad
                            )

                            HStack {
                                Text("Kite state")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Picker("Kite State", selection: $viewModel.state) {
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
                                Text("Optional: add a photo stored locally in SwiftData.")
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
        .navigationTitle("New Kite")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Create") {
                    Task { await viewModel.save(onSuccess: { dismiss() }) }
                }
                .disabled(viewModel.isSaving || !viewModel.isInputValid)
            }
        }
        .overlay {
            if viewModel.isSaving {
                ProgressView("Creating…")
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
        AdminKiteCreateView()
    }
}
