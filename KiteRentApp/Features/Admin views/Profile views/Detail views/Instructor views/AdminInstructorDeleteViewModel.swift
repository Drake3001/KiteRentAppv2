import Foundation
import Combine

@MainActor
final class AdminInstructorDeleteViewModel: ObservableObject {
    @Published var isDeleting: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

    private let instructorManager: InstructorManagerProtocol
    private let userManager: UserManagerProtocol
    private let authManager: AuthenticationManagerProtocol

    init(
        instructorManager: InstructorManagerProtocol? = nil,
        userManager: UserManagerProtocol? = nil,
        authManager: AuthenticationManagerProtocol? = nil
    ) {
        self.instructorManager = instructorManager ?? InstructorManager.shared
        self.userManager = userManager ?? UserManager.shared
        self.authManager = authManager ?? AuthenticationManager.shared
    }

    /// Removes instructor rentals + instructor doc, then `users` doc, then Firebase Auth via callable `adminDeleteAuthUser`.
    func deleteInstructorCompletely(instructorId: String) async -> Bool {
        guard !isDeleting else { return false }
        isDeleting = true
        defer { isDeleting = false }

        do {
            try await instructorManager.deleteInstructor(instructorId: instructorId)

            do {
                try await userManager.deleteUser(userId: instructorId)
            } catch {
                // User document may already be missing; continue to Auth cleanup.
            }

            try await authManager.deleteRemoteAuthUser(targetUid: instructorId)
            return true
        } catch {
            errorMessage = "Failed to delete instructor: \(error.localizedDescription)"
            showErrorAlert = true
            return false
        }
    }
}
