//
//  ProfileView.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 22/11/2025.
//

import SwiftUI

struct ProfileView: View {
    @State private var selectedAdminView: AdminViewType = .kites

    enum AdminViewType: String, CaseIterable, Identifiable {
        case kites = "Kites"
        case instructors = "Instructors"
        case rentals = "Rentals"

        var id: String { self.rawValue }
    }

    let onOpenSettings: () -> Void

    var body: some View {
        ZStack {
            AdminGlassBackground()

            VStack(spacing: 0) {
                Picker("Admin View Selection", selection: $selectedAdminView) {
                    ForEach(AdminViewType.allCases) { viewType in
                        Text(viewType.rawValue).tag(viewType)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.bottom, 8)

                currentAdminContentView()
            }
        }
        .navigationTitle("Admin")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
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
