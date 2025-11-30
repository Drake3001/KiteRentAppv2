import SwiftUI

struct ReservationButtons: View {
    @Binding var showPopup: Bool
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    let viewModel: KiteReservationViewModel
    let kiteId: String
    let startTime: Date
    let endTime: Date
    let selectedInstructorId: String?
    var onReservationCreated: (() -> Void)? = nil
    
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
        let isDisabled = viewModel.isLoading || startTime > endTime

        return Button {
            Task {
                await viewModel.confirmReservation(
                    kiteId: kiteId,
                    instructorId: selectedInstructorId,
                    startTime: startTime,
                    endTime: endTime
                )
                if viewModel.didCreateReservation {
                    showPopup = false
                    onReservationCreated?()
                }
            }
        } label: {
            if viewModel.isLoading {
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
