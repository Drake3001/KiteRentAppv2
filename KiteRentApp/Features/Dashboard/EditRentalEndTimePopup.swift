import SwiftUI

struct EditRentalEndTimePopup: View {
    let rental: InstructorRental
    let onConfirm: (Date) -> Void
    let onClose: () -> Void

    @StateObject private var viewModel: EditRentalEndTimeViewModel
    
    init(rental: InstructorRental, onConfirm: @escaping (Date) -> Void, onClose: @escaping () -> Void) {
        self.rental = rental
        self.onConfirm = onConfirm
        self.onClose = onClose
        _viewModel = StateObject(wrappedValue: EditRentalEndTimeViewModel(rental: rental))
    }

    var body: some View {
        VStack(spacing: 10) {
            VStack(spacing: 8) {
                Text("Edit rental")
                    .font(.headline)
                    .fontWeight(.semibold)

                Text(rental.kiteName)
                    .font(.subheadline)
                    .foregroundColor(Color(.secondaryLabel))
            }

            TimePickerSection(
                title: "End time",
                hours: viewModel.hours,
                minutes: viewModel.validMinutes(for: viewModel.endHour),
                hour: $viewModel.endHour,
                minute: $viewModel.endMinute
            )
            .onChange(of: viewModel.endHour) { _, _ in
                viewModel.clampMinuteIfNeeded()
            }

            HStack(spacing: 16) {
                Button("Close", action: onClose)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(10)

                Button(action: confirm) {
                    Text("Confirm")
                        .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 10)
                .background(Color.blue.opacity(0.9))
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding(20)
        .frame(maxWidth: 280)
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(18)
        .shadow(radius: 10)
    }

    private func confirm() {
        guard let newEndTime = viewModel.validate() else { return }
        onConfirm(newEndTime)
    }
}

