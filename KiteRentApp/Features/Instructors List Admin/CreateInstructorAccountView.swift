import SwiftUI

struct CreateInstructorAccountView: View {
    @StateObject private var viewModel = CreateInstructorAccountViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Instructor Info")) {
                    TextField("Name", text: $viewModel.name)
                        .textContentType(.givenName)
                    TextField("Surname", text: $viewModel.surname)
                        .textContentType(.familyName)
                    TextField("Phone number (optional)", text: $viewModel.phoneNumber)
                        .keyboardType(.phonePad)
                }

                Section(header: Text("Account Credentials")) {
                    TextField("Email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .textContentType(.emailAddress)
                    SecureField("Password", text: $viewModel.password)
                        .textContentType(.newPassword)
                }

                Button {
                    Task { await viewModel.createAccount() }
                } label: {
                    if viewModel.isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        Text("Create Instructor Account")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .disabled(viewModel.isSaving)

                if let success = viewModel.successMessage {
                    Text(success)
                        .foregroundColor(.green)
                }

                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                }
            }
            .navigationTitle("New Instructor")
        }
    }
}

#Preview {
    CreateInstructorAccountView()
}
