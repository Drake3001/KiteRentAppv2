import Combine
import FirebaseFirestore
import Foundation

@MainActor
final class EditInstructorProfileViewModel: ObservableObject {
    @Published var editableName: String = ""
    @Published var editableSurname: String = ""
    @Published var editablePhoneNumber: String = ""

    @Published var displayImageData: Data?
    private var imageDataOnLoad: Data?

    @Published private(set) var isLoadingInitial = false
    @Published var isSaving = false
    @Published var showErrorAlert = false
    @Published var errorMessage = ""

    private var originalInstructor: DBInstructor?
    private var processedPick: MediaProcessor.Result?

    private let authManager: AuthenticationManagerProtocol
    private let instructorManager: InstructorManagerProtocol
    private let mediaRepository: MediaRepositoryProtocol

    private(set) var instructorId: String?

    init(
        authManager: AuthenticationManagerProtocol? = nil,
        instructorManager: InstructorManagerProtocol? = nil,
        mediaRepository: MediaRepositoryProtocol? = nil
    ) {
        self.authManager = authManager ?? AuthenticationManager.shared
        self.instructorManager = instructorManager ?? InstructorManager.shared
        self.mediaRepository = mediaRepository ?? MediaRepository.shared
    }

    var isInputValid: Bool {
        !editableName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !editableSurname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var hasFieldChanges: Bool {
        guard let original = originalInstructor else { return false }
        let trimmedPhone = editablePhoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
        let originalPhone = original.phoneNumber ?? ""
        return editableName != original.name ||
            editableSurname != original.surname ||
            trimmedPhone != originalPhone
    }

    var hasImageChange: Bool {
        displayImageData != imageDataOnLoad
    }

    var hasAnyChanges: Bool {
        hasFieldChanges || hasImageChange
    }

    func applyPickedMedia(_ result: MediaProcessor.Result) {
        processedPick = result
        displayImageData = result.data
    }

    func clearImage() {
        displayImageData = nil
        processedPick = nil
    }

    func loadInitial() async {
        guard !isLoadingInitial else { return }
        isLoadingInitial = true
        defer { isLoadingInitial = false }
        errorMessage = ""
        do {
            let uid = try authManager.getAuthenticatedUser().uid
            instructorId = uid
            let instructor = try await instructorManager.getInstructor(instructorId: uid)
            originalInstructor = instructor
            editableName = instructor.name
            editableSurname = instructor.surname
            editablePhoneNumber = instructor.phoneNumber ?? ""

            let imageData = try await mediaRepository.getImageData(ownerType: .userProfile, ownerId: uid)
            imageDataOnLoad = imageData
            displayImageData = imageData
            processedPick = nil
        } catch {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }

    func save(onSuccess: @escaping () -> Void) async {
        guard isInputValid else {
            errorMessage = "Name and surname are required."
            showErrorAlert = true
            return
        }
        guard let original = originalInstructor, let uid = instructorId else {
            errorMessage = "Profile is not loaded."
            showErrorAlert = true
            return
        }

        guard hasAnyChanges else {
            onSuccess()
            return
        }

        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }

        let trimmedName = editableName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedSurname = editableSurname.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = editablePhoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)

        var fieldsToUpdate: [String: Any] = [:]

        if trimmedName != original.name {
            fieldsToUpdate["name"] = trimmedName
        }
        if trimmedSurname != original.surname {
            fieldsToUpdate["surname"] = trimmedSurname
        }

        let originalPhone = original.phoneNumber ?? ""
        if trimmedPhone != originalPhone {
            if trimmedPhone.isEmpty {
                if original.phoneNumber != nil {
                    fieldsToUpdate["phone_number"] = FieldValue.delete()
                }
            } else {
                fieldsToUpdate["phone_number"] = trimmedPhone
            }
        }

        do {
            if !fieldsToUpdate.isEmpty {
                try await instructorManager.updateInstructorFields(instructorId: uid, fields: fieldsToUpdate)
            }

            if hasImageChange {
                if let pick = processedPick {
                    try await mediaRepository.setImageData(
                        ownerType: .userProfile,
                        ownerId: uid,
                        data: pick.data,
                        mimeType: pick.mimeType,
                        thumbnailData: pick.thumbnailData,
                        width: pick.pixelWidth,
                        height: pick.pixelHeight
                    )
                } else if imageDataOnLoad != nil {
                    try await mediaRepository.deleteImage(ownerType: .userProfile, ownerId: uid)
                }
                imageDataOnLoad = displayImageData
                processedPick = nil
            }

            originalInstructor = DBInstructor(
                instructorId: uid,
                name: trimmedName,
                surname: trimmedSurname,
                phoneNumber: trimmedPhone.isEmpty ? nil : trimmedPhone,
                dateCreated: original.dateCreated,
                state: original.state
            )

            onSuccess()
        } catch {
            errorMessage = "Failed to save: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }
}
