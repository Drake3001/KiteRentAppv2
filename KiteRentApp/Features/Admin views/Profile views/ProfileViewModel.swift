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
    
//    @Published private(set) var user: AuthDataResultModel? = nil
    @Published private(set) var user: DBUser? = nil

    
//    func loadCurrentUser() throws{
////        self.user = try AuthenticationManager.shared.getAuthenticatedUser()
//    }
    func loadCurrentUser() async throws{
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
}
