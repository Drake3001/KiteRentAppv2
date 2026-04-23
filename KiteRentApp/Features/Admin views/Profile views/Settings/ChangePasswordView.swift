import SwiftUI

struct ChangePasswordView: View {
    @StateObject private var viewModel = ChangePasswordViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Current")
                            .frame(width: 60, alignment: .leading)
                        SecureField("enter password", text: $viewModel.currentPassword)
                    }
                    
                    HStack {
                        Text("New")
                            .frame(width: 60, alignment: .leading)
                        SecureField("enter password", text: $viewModel.newPassword)
                    }
                    
                    HStack {
                        Text("Verify")
                            .frame(width: 60, alignment: .leading)
                        SecureField("re-enter password", text: $viewModel.verifyPassword)
                    }
                }
                
                Section {
                    Text("Your password must be at least 8 characters, include a number, an uppercase letter, and a lowercase letter.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                
                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.blue)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Change") {
                        Task {
                            await viewModel.changePassword()
                            if viewModel.isSuccess {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.canSubmit || viewModel.isLoading)
                    .fontWeight(.semibold)
                    .foregroundStyle(viewModel.canSubmit && !viewModel.isLoading ? .blue : .gray)
                }
            }
            .disabled(viewModel.isLoading)
        }
    }
}

#Preview("Light") {
    ChangePasswordView()
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    ChangePasswordView()
        .preferredColorScheme(.dark)
}
