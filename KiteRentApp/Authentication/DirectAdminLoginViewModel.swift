import Foundation
import Combine

@MainActor
final class DirectAdminLoginViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    @Published var errorMessage: String? = nil
    
    func signUp() async throws {
        errorMessage = nil
        
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        
        do {
            let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
            let user = DBUser(userId: authDataResult.uid, email: authDataResult.email, dateCreated: Date())
            try await UserManager.shared.createNewUser(user: user)
        } catch {
             handleAuthError(error)
             throw error
        }
    }
    
    func signIn() async throws {
        errorMessage = nil
        
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            return
        }
        
        do {
            try await AuthenticationManager.shared.signInUser(email: email, password: password)
        } catch {
            handleAuthError(error)
            
            throw error
        }
    }
    
    private func handleAuthError(_ error: Error) {
        let errorDescription = error.localizedDescription.lowercased()
        
        if errorDescription.contains("wrong password") || errorDescription.contains("no user record") || errorDescription.contains("malformed") {
            errorMessage = "Invalid email or password. Please check your credentials and try again."
        } else if errorDescription.contains("invalid email") {
            errorMessage = "The email address format is invalid."
        } else if errorDescription.contains("network") {
            errorMessage = "A network error occurred. Check your internet connection."
        } else {
            // Fallback for unexpected errors
            errorMessage = "Authentication failed. \(error.localizedDescription)"
        }
    }
}
