//
//  ProfileView.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 22/11/2025.
//

import SwiftUI
import PhotosUI
import UIKit

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var profilePhotoPickerItem: PhotosPickerItem?
    
    @State private var selectedAdminView: AdminViewType = .kites
   
    enum AdminViewType: String, CaseIterable, Identifiable {
        case kites = "Kites"
        case instructors = "Instructors"
        case rentals = "Rentals"
        
        var id: String { self.rawValue }
    }
    
    let onOpenSettings: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 12) {
                profileAvatar
                if let email = viewModel.user?.email {
                    Text(email)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 12)

            Picker("Admin View Selection", selection: $selectedAdminView) {
                ForEach(AdminViewType.allCases) { viewType in
                    Text(viewType.rawValue).tag(viewType)
                }
            }
            .pickerStyle(.segmented)
            .padding([.horizontal, .bottom])
            
            currentAdminContentView()
        }
        .background(Color(.systemBackground))
        .task { try? await viewModel.loadCurrentUser() }
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

    private var profileAvatar: some View {
        HStack(spacing: 16) {
            Group {
                if let data = viewModel.profileImageData, let ui = UIImage(data: data) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.secondary)
                        .padding(12)
                }
            }
            .frame(width: 72, height: 72)
            .background(Color(.systemGray5))
            .clipShape(Circle())

            VStack(alignment: .leading, spacing: 8) {
                MediaPicker(
                    selection: $profilePhotoPickerItem,
                    label: "Choose profile photo",
                    onPicked: { data in
                        Task { await viewModel.setProfileImage(data: data) }
                    }
                )
                if viewModel.profileImageData != nil {
                    Button("Remove photo", role: .destructive) {
                        Task { await viewModel.clearProfileImage() }
                    }
                    .font(.subheadline)
                }
            }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
        private func currentAdminContentView() -> some View {
            switch selectedAdminView {
            case .kites:
                KiteListAdminView()
            case .instructors:
                InstructorListAdminView()
            case .rentals:
                RentalListAdminView()
            }
        }
}

#Preview("light") {
    NavigationStack {
        ProfileView(onOpenSettings: {})
    }
}

#Preview("dark") {
    NavigationStack {
        ProfileView(onOpenSettings: {})
            .preferredColorScheme(.dark)
    }
}


