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
            
            VStack {
                Spacer()
                
                Image(systemName: "wind")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                
                VStack(spacing: 0) {
                    Text("Kitesurfing")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    Text("School")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                }
                .padding(.top, 10)
                
                Spacer()
                
                VStack(spacing: 0) {
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
                .padding(.bottom, 12)
                
                Text("Przesuń w górę, aby rozpocząć")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.bottom, 40)
            }
            .padding(.horizontal, 20)
        }
        .gesture(
            DragGesture(minimumDistance: 30)
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

