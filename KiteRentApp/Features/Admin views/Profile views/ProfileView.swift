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
        ZStack {
            AdminGlassBackground()

            VStack(spacing: 0) {
                adminHeaderCard

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
        .task { try? await viewModel.loadCurrentUser() }
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

    private var adminHeaderCard: some View {
        GlassCard(cornerRadius: 22, material: .thinMaterial, contentPadding: 16) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 72, height: 72)
                        .overlay {
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.45),
                                            Color.white.opacity(0.1),
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        }

                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.secondary)
                        .padding(14)
                        .frame(width: 72, height: 72)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Administrator")
                        .font(.headline)
                        .fontWeight(.semibold)
                    if let email = viewModel.user?.email {
                        Text(email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
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
