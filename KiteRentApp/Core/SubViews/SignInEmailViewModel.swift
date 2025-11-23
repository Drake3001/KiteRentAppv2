//
//  SignInEmailViewModel.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 22/11/2025.
//

import Foundation
import Combine

@MainActor
final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws{
        guard !email.isEmpty, !password.isEmpty else {
                    // Handle empty fields
            return
        }
        
        
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
//        try await UserManager.shared.createNewUser(auth: authDataResult)
        let user = DBUser(userId: authDataResult.uid, email: authDataResult.email, dateCreated: Date())
        try await UserManager.shared.createNewUser(user: user)
    }
    
    func signIn() async throws{
        guard !email.isEmpty, !password.isEmpty else {
                    // Handle empty fields
            return
        }
        
    
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}
