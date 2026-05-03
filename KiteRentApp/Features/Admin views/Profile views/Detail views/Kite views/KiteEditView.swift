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
        NavigationView {
            VStack(spacing: 0) {
                Form {
                    Section(header: Text("Kite Details")) {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Name")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Enter name", text: $viewModel.editableName)
                                .autocorrectionDisabled()
                        }
                        
                        // --- 2. Brand Field ---
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Brand")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Enter brand", text: $viewModel.editableBrand)
                                .autocorrectionDisabled()
                        }
                        
                        // --- 3. Model Field ---
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Model")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("Enter model", text: $viewModel.editableModel)
                                .autocorrectionDisabled()
                        }
                        
                        // --- 4. Size Field ---
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Size (Meters)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            TextField("e.g., 9, 12", text: $viewModel.editableSize)
                                .keyboardType(.decimalPad)
                        }
                        
                        // --- 5. State Picker ---
                        Picker("Kite State", selection: $viewModel.editableState) {
                            ForEach(KiteState.allCases) { state in
                                Text(state.rawValue.capitalized).tag(state)
                            }
                        }
                        .disabled(KiteState.allCases.isEmpty)
                    }

                    Section(header: Text("Photo")) {
                        HStack {
                            MediaPicker(
                                selection: $photoPickerItem,
                                label: "Choose photo",
                                onPicked: { data in
                                    viewModel.setPickedImageData(data)
                                }
                            )
                            if viewModel.displayImageData != nil {
                                Button("Remove", role: .destructive) {
                                    viewModel.clearImage()
                                }
                            }
                        }
                        if let data = viewModel.displayImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        } else {
                            Text("No photo yet. Choose an image to store locally in SwiftData.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .navigationTitle("Edit \(viewModel.originalKite.name)")
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
                    .disabled(viewModel.isSaving || !viewModel.hasAnyChanges || !viewModel.isInputValid)
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
    let mock = DBKite(id: "123", name: "North reach 9", imageName: "reach9", state: .free, brand: "North", kiteModel: "Reach", size: "9", dateCreated: Date())
    KiteEditView(kite: mock)
}
