import SwiftUI

struct ReservationButtons: View {
    @Binding var showPopup: Bool
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    var isLargeScreen: Bool {
        hSizeClass == .regular
    }
    
    var body: some View {
        Group {
            if isLargeScreen {
                HStack(spacing: 16) {
                    confirmButton
                    closeButton
                }
            } else {
                VStack(spacing: 8) {
                    confirmButton
                    closeButton
                }
            }
        }
    }
    
    private var confirmButton: some View {
        Button("Potwierdź") {
            showPopup = false
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.9))
        .foregroundColor(.white)
        .cornerRadius(10)
    }
    
    private var closeButton: some View {
        Button("Zamknij") {
            showPopup = false
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.9))
        .foregroundColor(.white)
        .cornerRadius(10)
    }
}
