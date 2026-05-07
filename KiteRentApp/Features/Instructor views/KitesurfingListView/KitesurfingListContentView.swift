import SwiftUI

/// Shared grid, search, reservation popup, and scanner — used by `KitesurfingListView` and instructor tab.
struct KitesurfingListContentView: View {
    @ObservedObject var viewModel: KitesurfingListViewModel
    @FocusState private var isSearchFocused: Bool

    /// When nil, the login button is hidden (e.g. embedded instructor tab).
    var onLoginTapped: (() -> Void)?

    /// Public main flow keeps wind/login header; instructor profile uses toolbar wind + no header.
    var showsHeader: Bool = true

    /// Instructor shell presents scanner and errors on `InstructorProfileView`.
    var presentsScannerSheet: Bool = true
    var presentsErrorAlert: Bool = true

    /// When false, `InstructorProfileView` owns the reservation overlay (no duplicate popup).
    var showsReservationOverlay: Bool = true

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                if showsHeader {
                    HeaderView(
                        onWindTapped: { viewModel.showScanner = true },
                        onLoginTapped: onLoginTapped
                    )
                    .offset(y: -20)
                }

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
                    .background(Color(.systemGroupedBackground))
            }
            .background(Color(.systemBackground))
            .contentShape(Rectangle())

            if isSearchFocused {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        isSearchFocused = false
                    }
                    .zIndex(1)
            }

            if showsReservationOverlay, viewModel.showPopup, let kite = viewModel.selectedKite {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { viewModel.showPopup = false } }

                KiteReservationView(
                    showPopup: $viewModel.showPopup,
                    kite: kite,
                    mediaRefreshToken: viewModel.mediaRefreshToken,
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
        .modifier(KitesurfingChromeModifier(
            viewModel: viewModel,
            presentsErrorAlert: presentsErrorAlert,
            presentsScannerSheet: presentsScannerSheet
        ))
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
                        KitesurfingKiteGridItem(
                            kite: kite,
                            instructor: instructor,
                            mediaRefreshToken: viewModel.mediaRefreshToken,
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
}

struct KitesurfingKiteGridItem: View {
    let kite: DBKite
    let instructor: DBInstructor?
    let mediaRefreshToken: UUID
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            KiteCard(kite: kite, instructor: instructor, mediaRefreshToken: mediaRefreshToken)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .allowsHitTesting(kite.state == .free)
    }
}

private struct KitesurfingChromeModifier: ViewModifier {
    @ObservedObject var viewModel: KitesurfingListViewModel
    let presentsErrorAlert: Bool
    let presentsScannerSheet: Bool

    func body(content: Content) -> some View {
        Group {
            if presentsErrorAlert && presentsScannerSheet {
                content
                    .alert("Błąd", isPresented: $viewModel.showErrorAlert, actions: {
                        Button("OK") { viewModel.showErrorAlert = false }
                    }, message: { Text(viewModel.errorMessage ?? "") })
                    .fullScreenCover(isPresented: $viewModel.showScanner) {
                        QRScannerView(
                            onFound: { kiteId in
                                viewModel.showScanner = false
                                viewModel.handleScannedKite(kiteId: kiteId)
                            },
                            onCancel: { viewModel.showScanner = false }
                        )
                        .ignoresSafeArea()
                    }
            } else if presentsErrorAlert {
                content
                    .alert("Błąd", isPresented: $viewModel.showErrorAlert, actions: {
                        Button("OK") { viewModel.showErrorAlert = false }
                    }, message: { Text(viewModel.errorMessage ?? "") })
            } else if presentsScannerSheet {
                content
                    .fullScreenCover(isPresented: $viewModel.showScanner) {
                        QRScannerView(
                            onFound: { kiteId in
                                viewModel.showScanner = false
                                viewModel.handleScannedKite(kiteId: kiteId)
                            },
                            onCancel: { viewModel.showScanner = false }
                        )
                        .ignoresSafeArea()
                    }
            } else {
                content
            }
        }
    }
}
