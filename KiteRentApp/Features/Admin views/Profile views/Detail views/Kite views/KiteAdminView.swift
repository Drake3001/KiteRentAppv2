import SwiftUI

struct KiteAdminView: View {
    var kite: DBKite
    var mediaRefreshToken: UUID
    var mediaRepository: MediaRepositoryProtocol = MediaRepository.shared

    var onEditTapped: (DBKite) -> Void
    var onDeleteTapped: (DBKite) -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            HStack(alignment: .center, spacing: 12) {
                MediaImageView(
                    ownerType: .kite,
                    ownerId: kite.id ?? "",
                    mediaRepository: mediaRepository,
                    contentMode: .fit,
                    refreshToken: mediaRefreshToken
                )
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 8) {
                    Text(kite.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    TagView(text: textFromState(state: kite.state), backgroundColor: colorFromState(state: kite.state))
                }
                Spacer()
                
                Button {
                    onEditTapped(kite)
                } label: {
                    Image(systemName: "pencil")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                Button {
                    onDeleteTapped(kite)
                } label: {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                        .font(.title2)
                }
                
            }
            .padding()
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.primary.opacity(colorScheme == .dark ? 0.15 : 0.05), radius: 2, y: 4)
            
        }
        .frame(maxWidth: .infinity)
    }
    
    func textFromState(state: KiteState) -> String {
        switch state {
        case .free:
            return "Wolny"
        case .used:
            return "Na zajęciach"
        case .serviced:
            return "W serwisie"
        }
    }
    
    func colorFromState(state: KiteState) -> Color {
        switch state {
        case .free:
            return .green
        case .used:
            return .blue
        case .serviced:
            return .red
        }
    }
}

struct KiteAdmin_Previews: PreviewProvider {
    static var previews: some View {
        KiteAdminView(
            kite: DBKite(id: "demo", name: "Demo", imageName: "demo", state: .free, brand: "demo", kiteModel: "demo", size: "9", dateCreated: nil),
            mediaRefreshToken: UUID(),
            onEditTapped: { _ in },
            onDeleteTapped: { _ in }
        )
            .previewLayout(.sizeThatFits)
            .padding()
            .preferredColorScheme(.dark)
    }
}
