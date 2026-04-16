import SwiftUI

struct KiteReservationView: View {
    @Binding var showPopup: Bool
    
    @StateObject private var viewModel = KiteReservationViewModel()
    
    let kite: DBKite
    var onReservationCreated: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 10) {
            
            ReservationHeader(kite: kite)
            
            InstructorPickerSection(
                instructors: viewModel.filteredInstructors,
                selectedInstructor: $viewModel.selectedInstructor
            )
            
            TimePickerSection(
                title: "Godzina rozpoczęcia",
                hours: viewModel.startHours,
                minutes: viewModel.startMinutes,
                hour: $viewModel.startHour,
                minute: $viewModel.startMinute
            )
            
            TimePickerSection(
                title: "Godzina zakończenia",
                hours: viewModel.endHours,
                minutes: viewModel.endMinutes,
                hour: $viewModel.endHour,
                minute: $viewModel.endMinute
            )
            
            ReservationButtons(
                isLoading: viewModel.isLoading,
                isDisabled: viewModel.isConfirmDisabled,
                onConfirm: {
                    guard let kiteId = kite.id else { return }
                    Task {
                        await viewModel.confirmReservation(kiteId: kiteId)
                        if viewModel.didCreateReservation {
                            showPopup = false
                            onReservationCreated?()
                        }
                    }
                },
                onClose: { showPopup = false }
            )
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .padding(20)
        .frame(maxWidth: 280)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(radius: 10)
        .task {
            await viewModel.loadInstructors()
        }
        .onChange(of: viewModel.startHour) { _, _ in
            viewModel.clampStartMinuteIfNeeded()
        }
    }
}

#Preview {
    KiteReservationView(showPopup: .constant(true),
                        kite: DBKite(id: "demo", name: "Demo", imageName: "demo", state: .free, brand: "demo", kiteModel: "demo", size: "9", dateCreated: nil))
}
