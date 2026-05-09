import SwiftUI

struct ReservationButtons: View {
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    let isLoading: Bool
    let isDisabled: Bool
    let onConfirm: () -> Void
    let onClose: () -> Void
    
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
        Button(action: onConfirm) {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                Text("Potwierdź")
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 10)
        .background(isDisabled ? Color.gray.opacity(0.5) : Color.blue.opacity(0.9))
        .foregroundColor(.white.opacity(isDisabled ? 0.6 : 1.0))
        .cornerRadius(10)
        .disabled(isDisabled)
    }

    private var closeButton: some View {
        Button("Zamknij", action: onClose)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.9))
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}
