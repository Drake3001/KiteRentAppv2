import SwiftUI

struct KiteAdminView: View {
    var kite: DBKite
    var mediaRefreshToken: UUID
    var mediaRepository: MediaRepositoryProtocol = MediaRepository.shared

    var onEditTapped: (DBKite) -> Void
    var onDeleteTapped: (DBKite) -> Void

    var body: some View {
        GlassCard(cornerRadius: 22, material: .thinMaterial, contentPadding: 14) {
            HStack(alignment: .center, spacing: 12) {
                MediaImageView(
                    ownerType: .kite,
                    ownerId: kite.id ?? "",
                    mediaRepository: mediaRepository,
                    contentMode: .fit,
                    refreshToken: mediaRefreshToken
                )
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(kite.name)
                        .font(.title3)
                        .fontWeight(.bold)
                        .lineLimit(1)

                    HStack {
                        TagView(text: textFromState(state: kite.state), backgroundColor: colorFromState(state: kite.state))
                        
                        Spacer(minLength: 8)
                        
                        Button {
                            onEditTapped(kite)
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .font(.system(size: 34))
                                .foregroundStyle(.secondary)
                        }
                        .buttonStyle(.plain)

                        Button {
                            onDeleteTapped(kite)
                        } label: {
                            Image(systemName: "trash.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                                .font(.system(size: 34))
                                .foregroundStyle(.red)
                        }
                        .buttonStyle(.plain)
                    }
                    
                }

                
            }
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
        ZStack {
            AdminGlassBackground()
            KiteAdminView(
                kite: DBKite(id: "demo", name: "Demo", imageName: "demo", state: .free, brand: "demo", kiteModel: "demo", size: "9", dateCreated: nil),
                mediaRefreshToken: UUID(),
                onEditTapped: { _ in },
                onDeleteTapped: { _ in }
            )
            .padding()
        }
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}
