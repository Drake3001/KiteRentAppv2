import Foundation
import Combine

@MainActor
final class AdminKiteCreateViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var brand: String = ""
    @Published var model: String = ""
    @Published var size: String = ""
    @Published var state: KiteState = .free

    @Published var displayImageData: Data?

    @Published var isSaving: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

    private let kiteManager: KiteManagerProtocol
    private let mediaRepository: MediaRepositoryProtocol

    init(
        kiteManager: KiteManagerProtocol? = nil,
        mediaRepository: MediaRepositoryProtocol? = nil
    ) {
        self.kiteManager = kiteManager ?? KiteManager.shared
        self.mediaRepository = mediaRepository ?? MediaRepository.shared
    }

    var isInputValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !brand.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !model.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        Double(size.trimmingCharacters(in: .whitespacesAndNewlines)) != nil
    }

    func setPickedImageData(_ data: Data) {
        if let jpg = ImageDownscale.jpegDataResized(data) {
            displayImageData = jpg
        } else {
            displayImageData = data
        }
    }

    func clearImage() {
        displayImageData = nil
    }

    func save(onSuccess: @escaping () -> Void) async {
        let trimmedSize = size.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let sizeValue = Double(trimmedSize) else {
            errorMessage = "Please enter a valid size."
            showErrorAlert = true
            return
        }

        guard isInputValid else {
            errorMessage = "Please ensure all fields are valid."
            showErrorAlert = true
            return
        }

        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }

        let kiteId = UUID().uuidString
        let kite = DBKite(
            id: kiteId,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            imageName: "",
            state: state,
            brand: brand.trimmingCharacters(in: .whitespacesAndNewlines),
            kiteModel: model.trimmingCharacters(in: .whitespacesAndNewlines),
            size: String(sizeValue),
            dateCreated: Date()
        )

        do {
            try await kiteManager.createNewKite(kite: kite)
            if let data = displayImageData {
                try await mediaRepository.setImageData(ownerType: .kite, ownerId: kiteId, data: data)
            }
            onSuccess()
        } catch {
            errorMessage = "Failed to create kite: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
}
