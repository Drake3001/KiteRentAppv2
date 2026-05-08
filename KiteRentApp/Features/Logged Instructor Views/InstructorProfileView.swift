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

            if kitesViewModel.showPopup,
               let kite = kitesViewModel.selectedKite {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { kitesViewModel.showPopup = false } }

                Group {
                    if let instructor = profileViewModel.instructor {
                        InstructorKiteReservationView(
                            showPopup: $kitesViewModel.showPopup,
                            kite: kite,
                            instructor: instructor,
                            onReservationCreated: {
                                Task { await kitesViewModel.loadKites() }
                            }
                        )
                    } else if let error = profileViewModel.errorMessage, !error.isEmpty {
                        VStack(spacing: 10) {
                            Text("Błąd")
                                .font(.headline)
                            Text(error)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                            Button("Zamknij") { kitesViewModel.showPopup = false }
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue.opacity(0.9))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(20)
                        .frame(maxWidth: 280)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(18)
                        .shadow(radius: 10)
                    } else {
                        VStack(spacing: 12) {
                            ProgressView("Ładowanie…")
                        }
                        .padding(20)
                        .frame(maxWidth: 280)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(18)
                        .shadow(radius: 10)
                    }
                }
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
                    Text(instructor.shortName)
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
