import Foundation
import Combine
#if DEBUG
import FirebaseAuth
#endif

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
            #if DEBUG
            print("\(Self.logPrefix) validation failed: name or surname empty")
            #endif
            errorMessage = "Name and surname are required."
            return
        }
        guard !email.isEmpty, !password.isEmpty else {
            #if DEBUG
            print("\(Self.logPrefix) validation failed: email or password empty")
            #endif
            errorMessage = "Email and password are required."
            return
        }

        isSaving = true
        errorMessage = nil
        successMessage = nil

        #if DEBUG
        print("\(Self.logPrefix) start name=\(name) \(surname) email=\(email)")
        #endif

        do {
            #if DEBUG
            print("\(Self.logPrefix) before createUser currentAuthUid=\(Auth.auth().currentUser?.uid ?? "nil")")
            #endif
            let authResult = try await authManager.createUser(email: email, password: password)
            #if DEBUG
            print("\(Self.logPrefix) after createUser newUid=\(authResult.uid) email=\(authResult.email ?? "nil") currentAuthUid=\(Auth.auth().currentUser?.uid ?? "nil")")
            #endif

            let user = DBUser(
                userId: authResult.uid,
                email: authResult.email,
                dateCreated: Date(),
                role: .instructor
            )
            #if DEBUG
            print("\(Self.logPrefix) before createNewUser users/\(user.userId)")
            #endif
            try await userManager.createNewUser(user: user)
            #if DEBUG
            print("\(Self.logPrefix) after createNewUser OK")
            #endif

            let instructor = DBInstructor(
                instructorId: authResult.uid,
                name: name,
                surname: surname,
                phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
                dateCreated: Date(),
                state: .active
            )
            #if DEBUG
            print("\(Self.logPrefix) before createInstructor instructors/\(instructor.instructorId)")
            #endif
            try await instructorManager.createInstructor(instructor: instructor)
            #if DEBUG
            print("\(Self.logPrefix) after createInstructor OK")
            #endif

            // Sign out so the current admin session is not replaced
            #if DEBUG
            print("\(Self.logPrefix) before signOut currentAuthUid=\(Auth.auth().currentUser?.uid ?? "nil")")
            #endif
            try authManager.signOut()
            #if DEBUG
            print("\(Self.logPrefix) after signOut currentAuthUid=\(Auth.auth().currentUser?.uid ?? "nil")")
            #endif

            successMessage = "Instructor account created for \(name) \(surname)."
            clearForm()
            #if DEBUG
            print("\(Self.logPrefix) success, form cleared")
            #endif
        } catch {
            #if DEBUG
            print("\(Self.logPrefix) FAILED error=\(error)")
            print("\(Self.logPrefix) FAILED localized=\(error.localizedDescription)")
            let ns = error as NSError
            print("\(Self.logPrefix) FAILED domain=\(ns.domain) code=\(ns.code) userInfo=\(ns.userInfo)")
            #endif
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
