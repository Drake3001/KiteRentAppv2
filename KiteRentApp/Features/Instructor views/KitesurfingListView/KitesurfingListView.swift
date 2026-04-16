import SwiftUI

struct KitesurfingListView: View {
    @StateObject private var viewModel = KitesurfingListViewModel()
    
    @FocusState private var isSearchFocused: Bool
    
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
                        onWindTapped: { viewModel.showScanner = true },
                        onLoginTapped: { path.append(Destination.adminLogin) }
                    )
                    .offset(y: -20)
                    
                    SearchBarView(text: $viewModel.searchText)
                        .focused($isSearchFocused)
                    
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
                .contentShape(Rectangle())
//                .onTapGesture {
//                    isSearchFocused = false
//                }
                if isSearchFocused {
                    Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        isSearchFocused = false
                    }
                    .zIndex(1)
                }
                
                if viewModel.showPopup, let kite = viewModel.selectedKite {
                    Color.black.opacity(0.35)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { viewModel.showPopup = false } }
                    
                    KiteReservationView(
                        showPopup: $viewModel.showPopup,
                        kite: kite,
                        onReservationCreated: {
                            Task { await viewModel.loadKites() }
                        }
                    )
                    .transition(.scale)
                    .zIndex(10)
                }
            }
            .animation(.spring(), value: viewModel.showPopup)
            .task {
                await viewModel.loadKites()
                await viewModel.startRefreshOnRentalEnd()
            }
            .onDisappear {
                Task {
                    await viewModel.stopRefreshOnRentalEnd()
                }
            }
            .alert("Błąd", isPresented: $viewModel.showErrorAlert, actions: {
                Button("OK") { viewModel.showErrorAlert = false }
            }, message: { Text(viewModel.errorMessage ?? "") })
            .fullScreenCover(isPresented: $viewModel.showScanner) {
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
                            onTap: { viewModel.selectKite(kite) }
                        )
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
            .refreshable { await viewModel.loadKites() }
        }
    }
    
    @ViewBuilder
    private func scannerSheet() -> some View {
        QRScannerView(
            onFound: { kiteId in
                viewModel.showScanner = false
                viewModel.handleScannedKite(kiteId: kiteId)
            },
            onCancel: { viewModel.showScanner = false }
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
