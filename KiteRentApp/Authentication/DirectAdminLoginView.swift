//
//  DirectAdminLoginView.swift
//  KiteRentApp
//
//  Created by Filip on 06/12/2025.
//


import SwiftUI

struct DirectAdminLoginView: View {
    @StateObject private var viewModel = DirectAdminLoginViewModel()
    let onLoginSuccess: () -> Void
    
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.6),
                    Color.blue
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // White Card
                VStack(spacing: 20) {
                    
                    // Shield icon
                    Image(systemName: "shield.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                    
                    Text("DirectAdminLogin")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    // Email field
                    TextField("email@domain.com", text: $viewModel.email)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .textInputAutocapitalization(.never)
                    
                    
                    // Password field
                    SecureField("***********", text: $viewModel.password)
                        .padding()
                        .background(Color(.systemGray6))
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
                                .frame(maxWidth: .infinity)
                                .padding()
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    
                }
                .background(Color.white)
                .cornerRadius(30)
                .shadow(radius: 12)
                .padding(.horizontal, 30)
                
                Spacer()
            }
        }
    }
}

struct DirectAdminLoginView_Previews: PreviewProvider {
    static var previews: some View {
        DirectAdminLoginView(onLoginSuccess: {})
    }
}
