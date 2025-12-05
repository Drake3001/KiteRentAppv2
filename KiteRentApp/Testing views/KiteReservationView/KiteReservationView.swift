import SwiftUI

struct KiteReservationView: View {
    @Binding var showPopup: Bool
    
    @StateObject private var viewModel = KiteReservationViewModel()
    @State private var selectedInstructor: DBInstructor?
    
    private static let times = KiteReservationViewModel.initTime()
        
    @State private var startHour: Int = KiteReservationView.times.startHour
    @State private var startMinute: Int = KiteReservationView.times.startMinute
    @State private var endHour: Int = KiteReservationView.times.endHour
    @State private var endMinute: Int = KiteReservationView.times.endMinute

    let minutes = Array(stride(from: 0, through: 55, by: 5))
    let hours = Array(AppConstants.defaultWorkStartHour ..< AppConstants.defaultWorkEndHour + 1)
    
    var kite: DBKite
    var onReservationCreated: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 10) {
            
            ReservationHeader(kite: kite)
            
            InstructorPickerSection(
                viewModel: viewModel,
                selectedInstructor: $selectedInstructor
            )
            
            TimePickerSection(
                title: "Godzina rozpoczęcia",
                hours: hours,
                minutes: minutes,
                hour: $startHour,
                minute: $startMinute
            )
            
            TimePickerSection(
                title: "Godzina zakończenia",
                hours: hours,
                minutes: minutes,
                hour: $endHour,
                minute: $endMinute
            )
            
            ReservationButtons(
                showPopup: $showPopup,
                viewModel: viewModel,
                kiteId: kite.id,
                startTime: makeDate(hour: startHour, minute: startMinute),
                endTime: makeDate(hour: endHour, minute: endMinute),
                selectedInstructorId: selectedInstructor?.instructorId ?? viewModel.selectedInstructorId,
                onReservationCreated: onReservationCreated
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
            if selectedInstructor == nil, let first = viewModel.instructors.first {
                selectedInstructor = first
            }
        }
    }
    
    private func makeDate(hour: Int, minute: Int) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = hour
        comps.minute = minute
        return Calendar.current.date(from: comps) ?? Date()
    }
}

#Preview {
    KiteReservationView(showPopup: .constant(true),
                        kite: DBKite(id: "demo", name: "Demo", imageName: "demo", state: .free, brand: "demo", kiteModel: "demo", size: "9", dateCreated: nil))
}