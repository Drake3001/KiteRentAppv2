import SwiftUI

struct KiteReservationView: View {
    @Binding var showPopup: Bool
    
    @StateObject private var viewModel = KiteReservationViewModel()
    @State private var selectedInstructor: DBInstructor?
    @State private var startHour = 9
    @State private var startMinute = 0
    @State private var endHour = 10
    @State private var endMinute = 30
    
    let minutes = Array(stride(from: 0, through: 60, by: 5))
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
            
            ReservationButtons(showPopup: $showPopup)
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
}

#Preview {
    KiteReservationView(showPopup: .constant(true),
                        kite: DBKite(id: "demo", name: "Demo", imageName: "demo", state: .free, brand: "demo", kiteModel: "demo", size: "9", dateCreated: nil))
}
