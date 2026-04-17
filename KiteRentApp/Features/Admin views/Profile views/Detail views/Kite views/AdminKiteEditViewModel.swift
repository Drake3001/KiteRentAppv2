import Foundation
import Combine

@MainActor
final class AdminKiteEditViewModel: ObservableObject {
    @Published var editableName: String
    @Published var editableSize: String
    @Published var editableModel: String
    @Published var editableBrand: String
    @Published var editableState: KiteState

    @Published var isSaving: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

    let originalKite: DBKite

    private let kiteManager: KiteManagerProtocol

    init(
        kite: DBKite,
        kiteManager: KiteManagerProtocol? = nil
    ) {
        self.originalKite = kite
        self.editableName = kite.name
        self.editableSize = String(kite.size)
        self.editableModel = kite.kiteModel
        self.editableBrand = kite.brand
        self.editableState = kite.state
        self.kiteManager = kiteManager ?? KiteManager.shared
    }

    var hasChanges: Bool {
        editableName != originalKite.name ||
        editableBrand != originalKite.brand ||
        editableModel != originalKite.kiteModel ||
        editableSize != String(originalKite.size) ||
        editableState != originalKite.state
    }

    var isInputValid: Bool {
        !editableName.isEmpty &&
        !editableBrand.isEmpty &&
        !editableModel.isEmpty &&
        Double(editableSize) != nil
    }

    func save(onSuccess: @escaping () -> Void) async {
        guard isInputValid, let kiteId = originalKite.id else {
            errorMessage = "Please ensure all fields are valid."
            showErrorAlert = true
            return
        }

        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }

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
            onSuccess()
            return
        }

        do {
            try await kiteManager.updateKiteFields(kiteId: kiteId, fields: fieldsToUpdate)
            onSuccess()
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
}

