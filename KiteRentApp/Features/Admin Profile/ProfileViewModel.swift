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

    private let authManager: AuthenticationManagerProtocol
    private let userManager: UserManagerProtocol

    init(
        authManager: AuthenticationManagerProtocol? = nil,
        userManager: UserManagerProtocol? = nil
    ) {
        self.authManager = authManager ?? AuthenticationManager.shared
        self.userManager = userManager ?? UserManager.shared
    }

    func loadCurrentUser() async throws {
        let authDataResult = try authManager.getAuthenticatedUser()
        self.profileUserId = authDataResult.uid
        self.user = try await userManager.getUser(userId: authDataResult.uid)
    }
}
