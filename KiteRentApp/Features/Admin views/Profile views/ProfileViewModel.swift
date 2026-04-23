//
//  ProfileViewModel.swift
//  KiteRentApp
//
//  Created by Filip on 09/12/2025.
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    @Published private(set) var profileUserId: String?
    @Published var profileImageData: Data?

    private let authManager: AuthenticationManagerProtocol
    private let userManager: UserManagerProtocol
    private let mediaRepository: MediaRepositoryProtocol

    init(
        authManager: AuthenticationManagerProtocol? = nil,
        userManager: UserManagerProtocol? = nil,
        mediaRepository: MediaRepositoryProtocol? = nil
    ) {
        self.authManager = authManager ?? AuthenticationManager.shared
        self.userManager = userManager ?? UserManager.shared
        self.mediaRepository = mediaRepository ?? MediaRepository.shared
    }

    func loadCurrentUser() async throws {
        let authDataResult = try authManager.getAuthenticatedUser()
        self.profileUserId = authDataResult.uid
        self.user = try await userManager.getUser(userId: authDataResult.uid)
        await loadProfileImage()
    }

    func loadProfileImage() async {
        guard let uid = profileUserId else {
            profileImageData = nil
            return
        }
        do {
            let data = try await mediaRepository.getImageData(ownerType: .userProfile, ownerId: uid)
            profileImageData = data
        } catch {
            profileImageData = nil
        }
    }

    func setProfileImage(data: Data) async {
        guard let uid = profileUserId else { return }
        let toStore = ImageDownscale.jpegDataResized(data) ?? data
        do {
            try await mediaRepository.setImageData(ownerType: .userProfile, ownerId: uid, data: toStore)
            profileImageData = toStore
        } catch {
            profileImageData = nil
        }
    }

    func clearProfileImage() async {
        guard let uid = profileUserId else { return }
        do {
            try await mediaRepository.deleteImage(ownerType: .userProfile, ownerId: uid)
            profileImageData = nil
        } catch {
            profileImageData = nil
        }
    }
}
