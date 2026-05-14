import Foundation
import Combine

@MainActor
final class AdminKiteDeleteViewModel: ObservableObject {
    @Published var isDeleting: Bool = false
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

    func deleteKite(kiteId: String) async -> Bool {
        guard !isDeleting else { return false }
        isDeleting = true
        defer { isDeleting = false }

        do {
            try await kiteManager.deleteKite(kiteId: kiteId)
            try? await mediaRepository.deleteImage(ownerType: .kite, ownerId: kiteId)
            return true
        } catch {
            errorMessage = "Failed to delete kite: \(error.localizedDescription)"
            showErrorAlert = true
            return false
        }
    }
}
