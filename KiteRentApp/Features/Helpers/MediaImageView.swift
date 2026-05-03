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

    @State private var imageData: Data?

    var body: some View {
        Group {
            if let data = imageData, let ui = UIImage(data: data) {
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
        return "\(ownerType.rawValue)-\(ownerId)-\(token)"
    }

    private func load() async {
        guard !ownerId.isEmpty else {
            imageData = nil
            return
        }
        do {
            imageData = try await mediaRepository.getImageData(ownerType: ownerType, ownerId: ownerId)
        } catch {
            imageData = nil
        }
    }
}

#Preview {
    MediaImageView(ownerType: .kite, ownerId: "test", mediaRepository: MediaRepository.shared)
        .frame(width: 200, height: 200)
}
