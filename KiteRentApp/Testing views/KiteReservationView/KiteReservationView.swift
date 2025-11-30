import SwiftUI

struct KiteReservationView: View {
    @Binding var showPopup: Bool
    
    @StateObject private var viewModel = KiteReservationViewModel()
    @State private var selectedInstructor: DBInstructor?
    @State private var startHour = 9
    @State private var startMinute = 0
    @State private var endHour = 10
    @State private var endMinute = 30
    
    let minutes = Array(stride(from: 0, through: 55, by: 5))
    let hours = Array(6..<22)
    
    var kite: DBKite
    
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
                selectedInstructorId: selectedInstructor?.instructorId ?? viewModel.selectedInstructorId
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
