import Foundation
import Combine
import FirebaseAuth

@MainActor
final class CreateInstructorAccountViewModel: ObservableObject {

    private static let logPrefix = "[CreateInstructor]"

    @Published var email = ""
    @Published var password = ""
    @Published var name = ""
    @Published var surname = ""
    @Published var phoneNumber = ""

    @Published var isSaving = false
    @Published var successMessage: String?
    @Published var errorMessage: String?

    private let authManager: AuthenticationManagerProtocol
    private let userManager: UserManagerProtocol
    private let instructorManager: InstructorManagerProtocol

    init(
        authManager: AuthenticationManagerProtocol? = nil,
        userManager: UserManagerProtocol? = nil,
        instructorManager: InstructorManagerProtocol? = nil
    ) {
        self.authManager = authManager ?? AuthenticationManager.shared
        self.userManager = userManager ?? UserManager.shared
        self.instructorManager = instructorManager ?? InstructorManager.shared
    }

    func createAccount() async {
        guard !name.isEmpty, !surname.isEmpty else {
            errorMessage = "Name and surname are required."
            return
        }
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password are required."
            return
        }

        isSaving = true
        errorMessage = nil
        successMessage = nil


        do {
            let authResult = try await authManager.createUser(email: email, password: password)

            let user = DBUser(
                userId: authResult.uid,
                email: authResult.email,
                dateCreated: Date(),
                role: .instructor
            )
            try await userManager.createNewUser(user: user)

            let instructor = DBInstructor(
                instructorId: authResult.uid,
                name: name,
                surname: surname,
                phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
                dateCreated: Date(),
                state: .active
            )
            try await instructorManager.createInstructor(instructor: instructor)

            // Sign out so the current admin session is not replaced
            try authManager.signOut()

            successMessage = "Instructor account created for \(name) \(surname)."
            clearForm()
        } catch {
            errorMessage = "Failed to create account: \(error.localizedDescription)"
        }

        isSaving = false
    }

    private func clearForm() {
        email = ""
        password = ""
        name = ""
        surname = ""
        phoneNumber = ""
    }
}
