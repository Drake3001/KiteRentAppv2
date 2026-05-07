import SwiftUI

struct InstructorProfileView: View {
    let onOpenSettings: () -> Void

    @StateObject private var profileViewModel = InstructorProfileViewModel()
    @StateObject private var kitesViewModel = KitesurfingListViewModel()

    @State private var selectedTab: InstructorTab = .dashboard

    enum InstructorTab: String, CaseIterable, Identifiable {
        case dashboard = "Dashboard"
        case kites = "Kites"
        case rentals = "Rentals"

        var id: String { rawValue }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TabView(selection: $selectedTab) {
                    InstructorDashboardView(viewModel: profileViewModel)
                        .tabItem {
                            Label(InstructorTab.dashboard.rawValue, systemImage: "calendar")
                        }
                        .tag(InstructorTab.dashboard)

                    InstructorKitesurfingTabView(viewModel: kitesViewModel)
                        .tabItem {
                            Label(InstructorTab.kites.rawValue, systemImage: "square.grid.2x2")
                        }
                        .tag(InstructorTab.kites)

                    RentalListInstructorView()
                        .tabItem {
                            Label(InstructorTab.rentals.rawValue, systemImage: "archivebox")
                        }
                        .tag(InstructorTab.rentals)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .glassEffect()
            }
            .background(Color(.systemBackground))

            if kitesViewModel.showPopup, let kite = kitesViewModel.selectedKite {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { kitesViewModel.showPopup = false } }

                KiteReservationView(
                    showPopup: $kitesViewModel.showPopup,
                    kite: kite,
                    mediaRefreshToken: kitesViewModel.mediaRefreshToken,
                    onReservationCreated: {
                        Task { await kitesViewModel.loadKites() }
                    }
                )
                .transition(.scale)
                .zIndex(10)
            }
        }
        .animation(.spring(), value: kitesViewModel.showPopup)
        .task { await profileViewModel.loadProfile() }
        .onChange(of: kitesViewModel.showScanner) { _, isShowing in
            if isShowing {
                Task { await kitesViewModel.loadKites() }
            }
        }
        .alert("Błąd", isPresented: $kitesViewModel.showErrorAlert) {
            Button("OK") { kitesViewModel.showErrorAlert = false }
        } message: {
            Text(kitesViewModel.errorMessage ?? "")
        }
        .fullScreenCover(isPresented: $kitesViewModel.showScanner) {
            QRScannerView(
                onFound: { kiteId in
                    kitesViewModel.showScanner = false
                    Task {
                        await kitesViewModel.handleScannedKiteWithReloadIfNeeded(kiteId: kiteId)
                    }
                },
                onCancel: { kitesViewModel.showScanner = false }
            )
            .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    kitesViewModel.showScanner = true
                } label: {
                    Image(systemName: "wind").font(.headline)
                }
            }
            ToolbarItem(placement: .principal) {
                if let instructor = profileViewModel.instructor {
                    Text(Self.shortDisplayName(for: instructor))
                        .font(.headline)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { onOpenSettings() } label: {
                    Image(systemName: "gear").font(.headline)
                }
            }
        }
    }

    private static func shortDisplayName(for instructor: DBInstructor) -> String {
        let name = instructor.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let surname = instructor.surname.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let first = surname.first else {
            return name
        }
        return "\(name) \(String(first).uppercased())."
    }
}


#Preview("light") {
    NavigationStack {
        InstructorProfileView(onOpenSettings: {})
    }
}

#Preview("dark") {
    NavigationStack {
        InstructorProfileView(onOpenSettings: {})
            .preferredColorScheme(.dark)
    }
}
