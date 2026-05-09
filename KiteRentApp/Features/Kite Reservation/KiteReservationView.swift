import SwiftUI

private struct KiteReservationFormView: View {
    @Binding var showPopup: Bool
    let kite: DBKite
    let instructorMode: ReservationInstructorMode
    var onReservationCreated: (() -> Void)? = nil

    @StateObject private var viewModel: KiteReservationViewModel

    init(
        showPopup: Binding<Bool>,
        kite: DBKite,
        instructorMode: ReservationInstructorMode,
        onReservationCreated: (() -> Void)? = nil
    ) {
        self._showPopup = showPopup
        self.kite = kite
        self.instructorMode = instructorMode
        self.onReservationCreated = onReservationCreated
        self._viewModel = StateObject(wrappedValue: KiteReservationViewModel(instructorMode: instructorMode))
    }

    var body: some View {
        VStack(spacing: 10) {
            
            ReservationHeader(kite: kite)

            switch instructorMode {
            case .selectable:
                InstructorPickerSection(
                    instructors: viewModel.filteredInstructors,
                    selectedInstructor: $viewModel.selectedInstructor
                )
            case .fixed:
                EmptyView()
            }
            
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
        .background(Color(.tertiarySystemBackground))
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

struct KiteReservationView: View {
    @Binding var showPopup: Bool
    let kite: DBKite
    var onReservationCreated: (() -> Void)? = nil

    var body: some View {
        KiteReservationFormView(
            showPopup: $showPopup,
            kite: kite,
            instructorMode: .selectable,
            onReservationCreated: onReservationCreated
        )
    }
}

struct InstructorKiteReservationView: View {
    @Binding var showPopup: Bool
    let kite: DBKite
    let instructor: DBInstructor
    var onReservationCreated: (() -> Void)? = nil

    var body: some View {
        KiteReservationFormView(
            showPopup: $showPopup,
            kite: kite,
            instructorMode: .fixed(instructor),
            onReservationCreated: onReservationCreated
        )
    }
}

struct KitesurfingReservationView_Previews: PreviewProvider {
    static var previews: some View {
        KiteReservationView(showPopup: .constant(true),
                            kite: DBKite(id: "demo", name: "Demo", imageName: "demo", state: .free, brand: "demo", kiteModel: "demo", size: "9", dateCreated: nil))
            .previewDisplayName("light")
        
        KiteReservationView(showPopup: .constant(true),
                            kite: DBKite(id: "demo", name: "Demo", imageName: "demo", state: .free, brand: "demo", kiteModel: "demo", size: "9", dateCreated: nil))
            .previewDisplayName("dark")
            .preferredColorScheme(.dark)
            
    }
}
