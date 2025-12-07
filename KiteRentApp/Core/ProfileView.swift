//
//  ProfileView.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 22/11/2025.
//

import SwiftUI
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

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
   
    let onOpenSettings: () -> Void
    
    var body: some View {
        List {
            if let user = viewModel.user {
                Text("UserID: \(user.userId)")
            }
        }
        .task { try? await viewModel.loadCurrentUser() }
        .navigationTitle("AdminView")
        .navigationBarBackButtonHidden(true) 
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    onOpenSettings()
                } label: {
                    Image(systemName: "gear").font(.headline)
                }
            }
        }
    }
}


