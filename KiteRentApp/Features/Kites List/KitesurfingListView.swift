import SwiftUI

struct KitesurfingListView: View {
    @StateObject private var viewModel = KitesurfingListViewModel()

    @State private var path = NavigationPath()
    @State private var instructorProfileReloadToken = 0

    enum Destination: Hashable {
        case adminLogin
        case profile
        case instructorProfile
        case settings(userRole: UserRole)
    }

    var body: some View {
        NavigationStack(path: $path) {
            KitesurfingListContentView(
                viewModel: viewModel
            )
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .adminLogin:
                    DirectAdminLoginView(onLoginSuccess: { role in
                        switch role {
                        case .admin:
                            path.append(Destination.profile)
                        case .instructor:
                            path.append(Destination.instructorProfile)
                        }
                    })
                case .profile:
                    ProfileView(
                        onOpenSettings: {
                            path.append(Destination.settings(userRole: .admin))
                        }
                    )
                case .instructorProfile:
                    InstructorProfileView(
                        onOpenSettings: {
                            path.append(Destination.settings(userRole: .instructor))
                        },
                        profileReloadToken: instructorProfileReloadToken
                    )
                case .settings(let userRole):
                    SettingsView(
                        userRole: userRole,
                        onLogout: { path = NavigationPath() },
                        onProfileUpdated: {
                            if userRole == .instructor {
                                instructorProfileReloadToken += 1
                            }
                        }
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.showScanner = true
                    } label: {
                        Image(systemName: "wind").font(.headline)
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        path.append(Destination.adminLogin)
                    } label: {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.headline)
                            .offset(x: 2.5)
                    }
                }
            }
        }
    }
}

struct KitesurfingListView_Previews: PreviewProvider {
    static var previews: some View {
        KitesurfingListView()
            .previewDisplayName("light")

        KitesurfingListView()
            .previewDisplayName("dark")
            .preferredColorScheme(.dark)
    }
}
