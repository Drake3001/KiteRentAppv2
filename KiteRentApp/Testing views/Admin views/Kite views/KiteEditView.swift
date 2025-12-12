import SwiftUI
import Foundation

struct KiteEditView: View {
    @Environment(\.dismiss) var dismiss
    
    let originalKite: DBKite
    
    @State private var editableName: String
    @State private var editableSize: String
    @State private var editableModel: String
    @State private var editableBrand: String
    @State private var editableState: KiteState
    
    @State private var isSaving: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    init(kite: DBKite) {
        self.originalKite = kite
        _editableName = State(initialValue: kite.name)
        _editableBrand = State(initialValue: kite.brand)
        _editableState = State(initialValue: kite.state)
        _editableSize = State(initialValue: String(kite.size))
        _editableModel = State(initialValue: kite.kiteModel)
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
                                TextField("Enter name", text: $editableName)
                                    .autocorrectionDisabled()
                            }
                            
                            // --- 2. Brand Field ---
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Brand")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Enter brand", text: $editableBrand)
                                    .autocorrectionDisabled()
                            }
                            
                            // --- 3. Model Field ---
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Model")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("Enter model", text: $editableModel)
                                    .autocorrectionDisabled()
                            }
                            
                            // --- 4. Size Field ---
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Size (Meters)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                TextField("e.g., 9, 12", text: $editableSize)
                                    .keyboardType(.decimalPad)
                            }
                            
                            // --- 5. State Picker ---
                            Picker("Kite State", selection: $editableState) {
                                ForEach(KiteState.allCases) { state in
                                    Text(state.rawValue.capitalized).tag(state)
                                }
                            }
                            .disabled(KiteState.allCases.isEmpty)
                        }
                    }
                   
                    Spacer()
                    
                    if let uiImage = UIImage(named: originalKite.imageName) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 250)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                    }
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("Edit \(originalKite.name)")
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
        return editableName != originalKite.name ||
               editableBrand != originalKite.brand ||
               editableModel != originalKite.kiteModel ||
               editableSize != String(originalKite.size) ||
               editableState != originalKite.state
    }
    
    private var isInputValid: Bool {
        return !editableName.isEmpty &&
               !editableBrand.isEmpty &&
               !editableModel.isEmpty &&
               Double(editableSize) != nil
    }
    
    private func saveChanges() async {
        guard isInputValid, let kiteId = originalKite.id else {
            alertMessage = "Please ensure all fields are valid."
            showAlert = true
            return
        }
        
        isSaving = true
        
        var fieldsToUpdate: [String: Any] = [:]
        
        if editableName != originalKite.name {
            fieldsToUpdate["name"] = editableName
        }
        if editableBrand != originalKite.brand {
            fieldsToUpdate["brand"] = editableBrand
        }
        if editableModel != originalKite.kiteModel {
            fieldsToUpdate["kiteModel"] = editableModel
        }
        if editableSize != String(originalKite.size), let sizeDouble = Double(editableSize) {
            fieldsToUpdate["size"] = sizeDouble
        }
        if editableState != originalKite.state {
            fieldsToUpdate["state"] = editableState.rawValue
        }
        
        guard !fieldsToUpdate.isEmpty else {
            isSaving = false
            dismiss()
            return
        }
        
        do {
            try await KiteManager.shared.updateKiteFields(kiteId: kiteId, fields: fieldsToUpdate)
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
    let mock = DBKite(id: "123", name: "North reach 9", imageName: "reach9", state: .free, brand: "North", kiteModel: "Reach", size: "9", dateCreated: Date())
    KiteEditView(kite: mock)
}
