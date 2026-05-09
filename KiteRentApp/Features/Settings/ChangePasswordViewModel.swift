import Foundation
import Combine

@MainActor
final class ChangePasswordViewModel: ObservableObject {
    
    @Published var currentPassword = ""
    @Published var newPassword = ""
    @Published var verifyPassword = ""
    @Published var errorMessage: String?
    @Published var isSuccess = false
    @Published var isLoading = false
    
    private let authManager: AuthenticationManagerProtocol
    
    init(authManager: AuthenticationManagerProtocol? = nil) {
        self.authManager = authManager ?? AuthenticationManager.shared
    }
    
    var passwordsMatch: Bool {
        !newPassword.isEmpty && newPassword == verifyPassword
    }
    
    var canSubmit: Bool {
        !currentPassword.isEmpty && !newPassword.isEmpty && !verifyPassword.isEmpty
    }
    
    var isPasswordStrong: Bool {
        let hasMinLength = newPassword.count >= 8
        let hasUppercase = newPassword.range(of: "[A-Z]", options: .regularExpression) != nil
        let hasLowercase = newPassword.range(of: "[a-z]", options: .regularExpression) != nil
        let hasNumber = newPassword.range(of: "[0-9]", options: .regularExpression) != nil
        return hasMinLength && hasUppercase && hasLowercase && hasNumber
    }
    
    func changePassword() async {
        errorMessage = nil
        isSuccess = false
        
        guard !currentPassword.isEmpty else {
            errorMessage = "Please enter your current password."
            return
        }
        
        guard isPasswordStrong else {
            errorMessage = "Your password must be at least 8 characters, include a number, an uppercase letter, and a lowercase letter."
            return
        }
        
        guard passwordsMatch else {
            errorMessage = "Passwords do not match."
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let user = try authManager.getAuthenticatedUser()
            guard let email = user.email else {
                errorMessage = "Unable to retrieve account email."
                return
            }
            
            try await authManager.reauthenticateUser(email: email, password: currentPassword)
            try await authManager.updatePassword(to: newPassword)
            isSuccess = true
        } catch {
            handleError(error)
        }
    }
    
    private func handleError(_ error: Error) {
        let description = error.localizedDescription.lowercased()
        
        if description.contains("wrong password") || description.contains("invalid") || description.contains("credential") {
            errorMessage = "Current password is incorrect."
        } else if description.contains("weak password") || description.contains("6 characters") {
            errorMessage = "New password is too weak. Please use a stronger password."
        } else if description.contains("network") {
            errorMessage = "A network error occurred. Check your internet connection."
        } else if description.contains("requires-recent-login") || description.contains("recent login") {
            errorMessage = "Session expired. Please log out and sign in again."
        } else {
            errorMessage = "Failed to change password. \(error.localizedDescription)"
        }
    }
}
