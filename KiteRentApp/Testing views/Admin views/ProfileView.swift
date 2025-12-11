//
//  ProfileView.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 22/11/2025.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
   
    let onOpenSettings: () -> Void    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            
            KiteListAdminView()
        }
        .background(Color.white)
        .task { try? await viewModel.loadCurrentUser() }
        .navigationTitle("AdminView")
        .navigationBarBackButtonHidden(true) 
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    
                } label: {
                    Image(systemName: "wind").font(.headline)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    onOpenSettings()
                } label: {
                    Image(systemName: "gear").font(.headline)
                }
            }
        }
    }
}

#Preview {
    ProfileView(onOpenSettings: {})
}


