//
//  ProfileView.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 22/11/2025.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var adminKitesViewModel = KitesurfingListViewModel()
    @StateObject private var adminInstructorsViewModel = InstructorListAdminViewModel()
    @StateObject private var adminRentalsViewModel = RentalListAdminViewModel()

    @State private var selectedTab: AdminTab = .kites

    enum AdminTab: String, CaseIterable, Identifiable {
        case kites = "Kites"
        case instructors = "Instructors"
        case rentals = "Rentals"

        var id: String { rawValue }
    }

    /// Passes `.admin` when opening settings from the admin panel.
    let onOpenSettings: (UserRole) -> Void

    var body: some View {
        TabView(selection: $selectedTab) {
            adminTab(.kites) {
                KiteListAdminView(viewModel: adminKitesViewModel)
            }
            .tabItem {
                Label(AdminTab.kites.rawValue, systemImage: "square.grid.2x2")
            }
            .tag(AdminTab.kites)

            adminTab(.instructors) {
                InstructorListAdminView(viewModel: adminInstructorsViewModel)
            }
            .tabItem {
                Label(AdminTab.instructors.rawValue, systemImage: "person")
            }
            .tag(AdminTab.instructors)

            adminTab(.rentals) {
                RentalListAdminView(viewModel: adminRentalsViewModel)
            }
            .tabItem {
                Label(AdminTab.rentals.rawValue, systemImage: "archivebox")
            }
            .tag(AdminTab.rentals)
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
                    onOpenSettings(.admin)
                } label: {
                    Image(systemName: "gear").font(.headline)
                }
            }
        }
    }

    @ViewBuilder
    private func adminTab<Content: View>(_ tab: AdminTab, @ViewBuilder content: () -> Content) -> some View {
        ZStack {
            AdminGlassBackground()

            if selectedTab == tab {
                content()
            } else {
                Color.clear
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("light") {
    NavigationStack {
        ProfileView(onOpenSettings: { _ in })
    }
}

#Preview("dark") {
    NavigationStack {
        ProfileView(onOpenSettings: { _ in })
            .preferredColorScheme(.dark)
    }
}
