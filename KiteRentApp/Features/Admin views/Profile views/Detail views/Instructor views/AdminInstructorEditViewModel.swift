import Foundation
import Combine

@MainActor
final class AdminInstructorEditViewModel: ObservableObject {
    @Published var editableName: String
    @Published var editableSurname: String
    @Published var editablePhoneNumber: String
    @Published var editableState: InstructorState

    @Published var isSaving: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String = ""

    let originalInstructor: DBInstructor

    private let instructorManager: InstructorManagerProtocol

    init(
        instructor: DBInstructor,
        instructorManager: InstructorManagerProtocol? = nil
    ) {
        self.originalInstructor = instructor
        self.editableName = instructor.name
        self.editableSurname = instructor.surname
        self.editablePhoneNumber = instructor.phoneNumber ?? ""
        self.editableState = instructor.state
        self.instructorManager = instructorManager ?? InstructorManager.shared
    }

    var hasChanges: Bool {
        editableName != originalInstructor.name ||
        editableSurname != originalInstructor.surname ||
        editablePhoneNumber != (originalInstructor.phoneNumber ?? "") ||
        editableState != originalInstructor.state
    }

    var isInputValid: Bool {
        !editableName.isEmpty &&
        !editableSurname.isEmpty &&
        !editablePhoneNumber.isEmpty
    }

    func save(onSuccess: @escaping () -> Void) async {
        guard isInputValid else {
            errorMessage = "Please ensure all fields are valid."
            showErrorAlert = true
            return
        }

        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }

        var fieldsToUpdate: [String: Any] = [:]

        if editableName != originalInstructor.name {
            fieldsToUpdate["name"] = editableName
        }
        if editableSurname != originalInstructor.surname {
            fieldsToUpdate["surname"] = editableSurname
        }
        if editablePhoneNumber != (originalInstructor.phoneNumber ?? "") {
            fieldsToUpdate["phone_number"] = editablePhoneNumber
        }
        if editableState != originalInstructor.state {
            fieldsToUpdate["state"] = editableState.rawValue
        }

        guard !fieldsToUpdate.isEmpty else {
            onSuccess()
            return
        }

        do {
            try await instructorManager.updateInstructorFields(
                instructorId: originalInstructor.instructorId,
                fields: fieldsToUpdate
            )
            onSuccess()
        } catch {
            errorMessage = "Failed to save changes: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
}

