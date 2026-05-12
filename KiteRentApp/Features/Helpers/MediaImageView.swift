//
//  MediaImageView.swift
//  KiteRentApp
//

import SwiftUI
import UIKit

/// Displays an image for an owner from `MediaRepository`, or a system placeholder.
struct MediaImageView: View {
    let ownerType: MediaOwnerType
    let ownerId: String
    var mediaRepository: MediaRepositoryProtocol
    var contentMode: ContentMode = .fit
    /// When this value changes, the view reloads from the repository (e.g. after a list refresh).
    var refreshToken: UUID? = nil
    /// When `true`, loads the stored thumbnail when available (better for list cells).
    var useThumbnail: Bool = false

    @State private var uiImage: UIImage?

    var body: some View {
        Group {
            if let ui = uiImage {
                Image(uiImage: ui)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .padding(20)
                    .foregroundColor(.gray)
                    .background(Color(.systemGray5))
            }
        }
        .task(id: taskIdentity) {
            await load()
        }
    }

    private var taskIdentity: String {
        let token = refreshToken.map { $0.uuidString } ?? "none"
        let thumb = useThumbnail ? "t" : "f"
        return "\(ownerType.rawValue)-\(ownerId)-\(token)-\(thumb)"
    }

    private func load() async {
        guard !ownerId.isEmpty else {
            await MainActor.run { uiImage = nil }
            return
        }
        do {
            let data: Data?
            if useThumbnail {
                data = try await mediaRepository.getThumbnailData(ownerType: ownerType, ownerId: ownerId)
            } else {
                data = try await mediaRepository.getImageData(ownerType: ownerType, ownerId: ownerId)
            }
            let decoded = await Task.detached(priority: .userInitiated) {
                data.flatMap { UIImage(data: $0) }
            }.value
            await MainActor.run { uiImage = decoded }
        } catch {
            await MainActor.run { uiImage = nil }
        }
    }
}

#Preview {
    MediaImageView(ownerType: .kite, ownerId: "test", mediaRepository: MediaRepository.shared)
        .frame(width: 200, height: 200)
}
