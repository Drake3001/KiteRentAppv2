import Combine
import Foundation

@MainActor
final class AdminKiteCreateViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var brand: String = ""
    @Published var model: String = ""
    @Published var size: String = ""
    @Published var state: KiteState = .free

    @Published var displayImageData: Data?
    /// Original bytes from the photo picker; used when toggling background removal.
    @Published private(set) var rawImageData: Data?
    @Published var removeBackground: Bool = false
    @Published var isProcessingImage: Bool = false

    @Published var isSaving: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

    private let kiteManager: KiteManagerProtocol
    private let mediaRepository: MediaRepositoryProtocol

    /// Latest processed result; used on save with correct mime, thumbnail, and dimensions.
    private var processedPick: MediaProcessor.Result?

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

    func applyRawPicked(_ data: Data) {
        rawImageData = data
        Task { await reprocessKiteImage() }
    }

    func reprocessKiteImage() async {
        guard let raw = rawImageData else { return }
        isProcessingImage = true
        defer { isProcessingImage = false }

        var preserveAlpha = false
        let working: Data
        if removeBackground {
            do {
                working = try await BackgroundRemover.removeBackground(from: raw)
                preserveAlpha = true
            } catch {
                errorMessage = "Could not remove background. Try on a physical device, or turn this option off."
                showErrorAlert = true
                working = raw
                preserveAlpha = false
            }
        } else {
            working = raw
        }

        do {
            let result = try await MediaProcessor.process(working, preserveAlpha: preserveAlpha)
            processedPick = result
            displayImageData = result.data
        } catch {
            errorMessage = "Could not process image: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }

    func clearImage() {
        rawImageData = nil
        displayImageData = nil
        processedPick = nil
        removeBackground = false
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

        guard !isProcessingImage else { return }
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
            }
            onSuccess()
        } catch {
            errorMessage = "Failed to create kite: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
}
