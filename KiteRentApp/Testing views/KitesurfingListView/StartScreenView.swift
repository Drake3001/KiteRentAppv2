import SwiftUI

struct StartScreenView: View {

    @State private var isShowingHistoryView = false
    
    @State private var arrowOffset: CGFloat = 0

    var body: some View {
        ZStack {
            
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(#colorLiteral(red: 0.2039, green: 0.7882, blue: 1.0, alpha: 1)),
                    Color(#colorLiteral(red: 0.0, green: 0.3647, blue: 1.0, alpha: 1))
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                
                Image(systemName: "wind")
                    .font(.system(size: 90))
                    .foregroundColor(.white)
                    .padding(.top, 80)
                
                VStack(spacing: 4) {
                    Text("Kitesurfing")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)
                    Text("School")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("System Ewidencji Sprzętu")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, -10)
                
                VStack(spacing: 6) {
                    Text("Zarządzaj sprzętem w czasie rzeczywistym")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                    
                    Text("Śledź dostępność • Skanuj QR • Historia użycia")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 20)
                
                Spacer()
                
                Text("Przesuń w górę, aby rozpocząć")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
                
                VStack(spacing: 4) {
                    Image(systemName: "chevron.up")
                    Image(systemName: "chevron.up")
                }
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .offset(y: arrowOffset)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                        arrowOffset = -10
                    }
                }
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 20)
        }
        .gesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.height < 0 {
                        isShowingHistoryView = true
                    }
                }
        )
        .fullScreenCover(isPresented: $isShowingHistoryView) {
            KitesurfingListView()
        }
    }
}

#Preview {
    StartScreenView()
}
