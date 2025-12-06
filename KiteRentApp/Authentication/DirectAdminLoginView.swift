//
//  DirectAdminLoginView.swift
//  KiteRentApp
//
//  Created by Filip on 06/12/2025.
//


import SwiftUI

struct DirectAdminLoginView: View {
    @StateObject private var viewModel = DirectAdminLoginViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        ZStack {
            // Background Gradient
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
                    
                    // Password field
                    SecureField("***********", text: $viewModel.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    
                    HStack(spacing: 20) {
                        Button(action: {}) {
                            Text("Cancel")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
                                .cornerRadius(10)
                        }
                        
                        Button {
                            Task {
                                do {
                                    try await viewModel.signUp()
                                    showSignInView = false
                                    return
                                } catch {
                                    print("error")
                                }
                                
                                do {
                                    try await viewModel.signIn()
                                    showSignInView = false
                                    return
                                } catch {
                                    print("error")
                                }
                            }
                        } label: {
                            Text("Sign In")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.black)
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
        DirectAdminLoginView(showSignInView: .constant(false))
    }
}
