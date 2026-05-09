import SwiftUI

struct KitesurfingListView: View {
    @StateObject private var viewModel = KitesurfingListViewModel()

    @State private var path = NavigationPath()

    enum Destination: Hashable {
        case adminLogin
        case profile
        case instructorProfile
        case settings
    }

    var body: some View {
        NavigationStack(path: $path) {
            KitesurfingListContentView(
                viewModel: viewModel,
                onLoginTapped: { path.append(Destination.adminLogin) }
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
                        onOpenSettings: { path.append(Destination.settings) }
                    )
                case .instructorProfile:
                    InstructorProfileView(
                        onOpenSettings: { path.append(Destination.settings) }
                    )
                case .settings:
                    SettingsView(
                        onLogout: { path = NavigationPath() }
                    )
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
