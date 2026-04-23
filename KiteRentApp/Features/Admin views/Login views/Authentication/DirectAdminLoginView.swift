//
//  DirectAdminLoginView.swift
//  KiteRentApp
//
//  Created by Filip on 06/12/2025.
//


import SwiftUI

struct DirectAdminLoginView: View {
    @StateObject private var viewModel = DirectAdminLoginViewModel()
    @Environment(\.colorScheme) private var colorScheme
    let onLoginSuccess: () -> Void
    
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: colorScheme == .dark
                    ? [Color.blue.opacity(0.3), Color.blue.opacity(0.6)]
                    : [Color.blue.opacity(0.6), Color.blue]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                VStack(spacing: 20) {
                    
                    Image(systemName: "shield.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                    
                    Text("DirectAdminLogin")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("email@domain.com", text: $viewModel.email)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .textInputAutocapitalization(.never)
                    
                    SecureField("***********", text: $viewModel.password)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .textInputAutocapitalization(.never)
                    
                    if let error = viewModel.errorMessage, !error.isEmpty {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    HStack(spacing: 20) {
                        Button {
                            Task {
                                do {
                                    try await viewModel.signIn()
                                    onLoginSuccess()
                                } catch {
                                    print("Sign in failed")
                                }
                            }
                        } label: {
                            Text("Sign In")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    
                }
                .background(Color(.systemBackground))
                .cornerRadius(30)
                .shadow(color: colorScheme == .dark ? .white.opacity(0.08) : .black.opacity(0.2), radius: 12)
                .padding(.horizontal, 30)
                
                Spacer()
            }
        }
    }
}

#Preview("Light Mode") {
    DirectAdminLoginView(onLoginSuccess: {})
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    DirectAdminLoginView(onLoginSuccess: {})
        .preferredColorScheme(.dark)
}
