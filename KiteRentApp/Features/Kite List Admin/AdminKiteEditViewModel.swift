import Foundation
import Combine

@MainActor
final class AdminKiteEditViewModel: ObservableObject {
    @Published var editableName: String
    @Published var editableSize: String
    @Published var editableModel: String
    @Published var editableBrand: String
    @Published var editableState: KiteState

    /// Shown in the editor; may differ from SwiftData until Save.
    @Published var displayImageData: Data?
    private var imageDataOnLoad: Data?

    @Published var isSaving: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

    let originalKite: DBKite

    private let kiteManager: KiteManagerProtocol
    private let mediaRepository: MediaRepositoryProtocol

    private var processedPick: MediaProcessor.Result?

    init(
        kite: DBKite,
        kiteManager: KiteManagerProtocol? = nil,
        mediaRepository: MediaRepositoryProtocol? = nil
    ) {
        self.originalKite = kite
        self.editableName = kite.name
        self.editableSize = String(kite.size)
        self.editableModel = kite.kiteModel
        self.editableBrand = kite.brand
        self.editableState = kite.state
        self.kiteManager = kiteManager ?? KiteManager.shared
        self.mediaRepository = mediaRepository ?? MediaRepository.shared
        Task { await loadImageFromRepository() }
    }

    var hasFieldChanges: Bool {
        editableName != originalKite.name ||
        editableBrand != originalKite.brand ||
        editableModel != originalKite.kiteModel ||
        editableSize != String(originalKite.size) ||
        editableState != originalKite.state
    }

    var hasImageChange: Bool {
        displayImageData != imageDataOnLoad
    }

    var hasAnyChanges: Bool {
        hasFieldChanges || hasImageChange
    }

    var isInputValid: Bool {
        !editableName.isEmpty &&
        !editableBrand.isEmpty &&
        !editableModel.isEmpty &&
        Double(editableSize) != nil
    }

    func loadImageFromRepository() async {
        guard let kiteId = originalKite.id else { return }
        do {
            let data = try await mediaRepository.getImageData(ownerType: .kite, ownerId: kiteId)
            imageDataOnLoad = data
            displayImageData = data
            processedPick = nil
        } catch {
            imageDataOnLoad = nil
            displayImageData = nil
            processedPick = nil
        }
    }

    func applyPickedMedia(_ result: MediaProcessor.Result) {
        processedPick = result
        displayImageData = result.data
    }

    func clearImage() {
        displayImageData = nil
        processedPick = nil
    }

    func save(onSuccess: @escaping () -> Void) async {
        guard isInputValid, let kiteId = originalKite.id else {
            errorMessage = "Please ensure all fields are valid."
            showErrorAlert = true
            return
        }

        guard hasAnyChanges else {
            onSuccess()
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

        do {
            if !fieldsToUpdate.isEmpty {
                try await kiteManager.updateKiteFields(kiteId: kiteId, fields: fieldsToUpdate)
            }

            if hasImageChange {
                if let pick = processedPick {
                    try await mediaRepository.setImageData(
                        ownerType: .kite,
                        ownerId: kiteId,
                        data: pick.data,
                        mimeType: pick.mimeType,
                        thumbnailData: pick.thumbnailData,
                        width: pick.pixelWidth,
                        height: pick.pixelHeight
                    )
                } else {
                    if imageDataOnLoad != nil {
                        try await mediaRepository.deleteImage(ownerType: .kite, ownerId: kiteId)
                    }
                }
                imageDataOnLoad = displayImageData
                processedPick = nil
            }

            onSuccess()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
}
