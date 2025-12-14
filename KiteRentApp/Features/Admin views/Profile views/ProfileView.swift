//
//  ProfileView.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 22/11/2025.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    
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
            Picker("Admin View Selection", selection: $selectedAdminView) {
                ForEach(AdminViewType.allCases) { viewType in
                    Text(viewType.rawValue).tag(viewType)
                }
            }
            .pickerStyle(.segmented)
            .padding([.horizontal, .bottom])
            
            currentAdminContentView()
        }
        .background(Color.white)
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

#Preview {
    NavigationStack {
        ProfileView(onOpenSettings: {})
    }
    
}


