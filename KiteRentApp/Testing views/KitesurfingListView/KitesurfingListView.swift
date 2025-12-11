import SwiftUI

struct KitesurfingListView: View {
    @StateObject private var viewModel = KitesurfingListViewModel()
    @State private var selectedKite: DBKite? = nil
    @State private var showPopup: Bool = false
    
    @State private var showScanner: Bool = false
    @State private var scannedKiteId: String = ""
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""
    
    @State private var path = NavigationPath()
    
    enum Destination: Hashable {
        case adminLogin
        case profile
        case settings
    }

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                VStack(spacing: 0) {
                    HeaderView(
                        onWindTapped: { showScanner = true },
                        onLoginTapped: { path.append(Destination.adminLogin) }
                    )
                    .offset(y: -20)
                    
                    SearchBarView(text: $viewModel.searchText)
                    
                    Spacer()
                    
                    FilterRowView(
                        numberOfElements: viewModel.filteredAndOrderedKites.count,
                        onSortTapped: { viewModel.isSortAscending.toggle() },
                        isAscending: viewModel.isSortAscending
                    )
                    
                    Spacer()
                    
                    content
                        .background(Color("LightGrayBackgroundColor"))
                }
                .background(Color.white)
                
                if showPopup, let kite = selectedKite {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { showPopup = false } }
                    
                    KiteReservationView(
                        showPopup: $showPopup,
                        kite: kite,
                        onReservationCreated: {
                            Task { await viewModel.loadKites() }
                        }
                    )
                    .transition(.scale)
                    .zIndex(10)
                }
            }
            .animation(.spring(), value: showPopup)
            .task {
                await viewModel.loadKites()
                await viewModel.startRefreshOnRentalEnd()
            }
            .onDisappear {
                Task {
                    await viewModel.stopRefreshOnRentalEnd()
                }
            }
            .alert("Błąd", isPresented: $showErrorAlert, actions: {
                Button("OK") { showErrorAlert = false }
            }, message: { Text(errorMessage) })
            .fullScreenCover(isPresented: $showScanner) {
                scannerSheet()
                    .ignoresSafeArea()
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .adminLogin:
                    DirectAdminLoginView(onLoginSuccess: {
                        path.append(Destination.profile)
                    })
                case .profile:
                    ProfileView(
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
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            VStack {
                ProgressView("Ładowanie…").padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.filteredAndOrderedKites) { kite in
                        let instructor = viewModel.getInstructorForKite(kiteId: kite.id ?? "")
                        KiteGridItem(
                            kite: kite,
                            instructor: instructor,
                            onTap: { handleKiteTap(kite) }
                        )
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .refreshable { await viewModel.loadKites() }
        }
    }
    
    private func handleKiteTap(_ kite: DBKite) {
        selectedKite = kite
        showPopup = kite.state == .free
    }
    
    private func handleScannedKite(kiteId: String) {
        if let kite = viewModel.filteredAndOrderedKites.first(where: { $0.id == kiteId }) {
            switch kite.state {
            case .free:
                selectedKite = kite
                showPopup = true
            case .used:
                errorMessage = "Kite \(kiteId) jest zajęty."
                showErrorAlert = true
            case .serviced:
                errorMessage = "Kite \(kiteId) jest niedostępny."
                showErrorAlert = true
            }
        } else {
            errorMessage = "Nie znaleziono kite o ID \(kiteId)."
            showErrorAlert = true
        }
    }
    
    @ViewBuilder
    private func scannerSheet() -> some View {
        QRScannerView(
            onFound: { kiteId in
                showScanner = false
                handleScannedKite(kiteId: kiteId)
            },
            onCancel: { showScanner = false }
        )
    }
}

private struct KiteGridItem: View {
    let kite: DBKite
    let instructor: DBInstructor?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            KiteCard(kite: kite, instructor: instructor)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .allowsHitTesting(kite.state == .free)
    }
}


struct KitesurfingListView_Previews: PreviewProvider {
    static var previews: some View {
        KitesurfingListView()
    }
}
