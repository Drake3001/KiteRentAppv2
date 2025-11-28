import SwiftUI

struct KitesurfingListView: View {
    @State var searchText = ""
    @State private var selectedKite: DBKite? = nil
    @State private var showPopup: Bool = false
    @State private var kites: [DBKite] = []
    @State private var loadingError: String?

    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                HeaderView()
                    .offset(y: -20)

                SearchBarView(text: $searchText)
                Spacer()
                // Pass the current count into the filter row (update FilterRowView to accept this)
                FilterRowView(numberOfKites: visibleKites.count)
                Spacer()

                VStack {
                    ScrollView {
                        VStack {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(visibleKites) { kite in
                                    Button {
                                        selectedKite = kite
                                        showPopup = kite.state == .free
                                    } label: {
                                        KiteCard(kite: kite) // Update KiteCard to accept DBKite
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    .allowsHitTesting(kite.state == .free)
                                }
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .background(Color(hex: "F7F8FA"))
            }
            .background(Color.white)

            if showPopup, let kite = selectedKite {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { showPopup = false } }

                KiteReservationView(showPopup: $showPopup, kite: kite) // Update to accept DBKite
                    .transition(.scale)
                    .zIndex(10)
            }
        }
        .animation(.spring(), value: showPopup)
        .task {
            await loadKites()
        }
        .alert("Error", isPresented: .constant(loadingError != nil), actions: {
            Button("OK") { loadingError = nil }
        }, message: {
            Text(loadingError ?? "")
        })
    }

    private var visibleKites: [DBKite] {
        if searchText.isEmpty {
            return kites
        } else {
            return kites.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    private func loadKites() async {
        do {
            let fetched = try await KiteManager.shared.getAllKites()
            // Ensure UI updates on main actor
            await MainActor.run {
                self.kites = fetched
            }
        } catch {
            await MainActor.run {
                self.loadingError = error.localizedDescription
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
