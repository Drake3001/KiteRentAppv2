import SwiftUI

struct KitesurfingListView: View {
    @State var searchText = ""
    @State private var selectedKite: Kite? = nil
    @State private var showPopup: Bool = false

    var kites: [Kite]
        
    //private let columns = [
      //  GridItem(.flexible(), spacing: 16),
        //GridItem(.flexible(), spacing: 16)
    //]
    private let columns = [
        GridItem(.adaptive(minimum: 150), spacing: 16)
    ]

    
    var body: some View {
        ZStack {   // <-- Needed for overlay popup
            VStack(spacing: 0) {
                HeaderView()
                    .offset(y: -20)

                SearchBarView(text: $searchText)
                Spacer()
                FilterRowView()
                Spacer()
                
                var visibleKites: [Kite] {
                    searchText.isEmpty
                        ? kites
                        : kites.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
                }

                VStack {
                    ScrollView {
                        VStack {
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(visibleKites) { kite in
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

                KiteReservationView(showPopup: $showPopup, kite: kite)
                .transition(.scale)
                .zIndex(10)
            }
        }
        .animation(.spring(), value: showPopup)
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
        KitesurfingListView(kites: kites)
    }
}
