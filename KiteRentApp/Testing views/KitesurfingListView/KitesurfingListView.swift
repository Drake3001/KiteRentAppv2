import SwiftUI

struct KitesurfingListView: View {
    @StateObject private var viewModel = KitesurfingListViewModel()
    @State private var selectedKite: DBKite? = nil
    @State private var showPopup: Bool = false

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView()
                    .offset(y: -20)

                SearchBarView(text: $viewModel.searchText)

                Spacer()

                FilterRowView(numberOfKites: viewModel.filteredKites.count)

                Spacer()

                content
                    .background(Color(hex: "F7F8FA"))
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
                        Task {
                            await viewModel.loadKites()
                        }
                    }
                )
                .transition(.scale)
                .zIndex(10)
            }
        }
        .animation(.spring(), value: showPopup)
        .task {
            await viewModel.loadKites()
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), actions: {
            Button("OK") { viewModel.errorMessage = nil }
        }, message: {
            Text(viewModel.errorMessage ?? "")
        })
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            VStack {
                ProgressView("Ładowanie…")
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.filteredKites) { kite in
                        Button {
                            selectedKite = kite
                            showPopup = kite.state == .free
                        } label: {
                            KiteCard(kite: kite)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .allowsHitTesting(kite.state == .free)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - HEX COLOR EXTENSION
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")

        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}

struct KitesurfingListView_Previews: PreviewProvider {
    static var previews: some View {
        KitesurfingListView()
    }
}