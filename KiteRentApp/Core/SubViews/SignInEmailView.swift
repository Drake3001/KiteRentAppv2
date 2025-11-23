//
//  SignInEmailView.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 21/11/2025.
//

import SwiftUI
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
        
        
        try await AuthenticationManager.shared.createUser(email: email, password: password)
    }
    
    func signIn() async throws{
        guard !email.isEmpty, !password.isEmpty else {
                    // Handle empty fields
            return
        }
        
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}

struct SignInEmailView: View {
    
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            TextField("Email...", text: $viewModel.email)
                
            SecureField("Password..", text: $viewModel.password)
            
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        showSignInView = false
                        return
                    } catch {
                        print("error")
                    }
                    
                    do {
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    } catch {
                        print("error")
                    }
                }
            } label: {
                Text("Sign In")
            }
        }
    }
}

//#Preview {
//    SignInEmailView()
//}
struct SignInEmailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SignInEmailView(showSignInView: .constant(false))
        }
    }
}
