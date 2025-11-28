import SwiftUI

struct KiteReservationView: View {
    @Binding var showPopup: Bool

    @State private var selectedInstructor = "Filip"
    @State private var startHour = 9
    @State private var startMinute = 0
    @State private var endHour = 10
    @State private var endMinute = 30

    let minutes = Array(stride(from: 0, to: 65, by: 5))
    let hours = Array(0..<24)
    let instructors = ["Filip", "Adam", "Tomek"]

    var kite: DBKite

    var body: some View {
        VStack(spacing: 10) {
            Text("Rezerwacja latawca")
                .font(.headline)
                .fontWeight(.semibold)

            Text(kite.name)
                .font(.subheadline)
                .foregroundColor(.gray)

            VStack(alignment: .leading, spacing: 6) {
                Text("Instruktor")
                    .font(.subheadline)

                Menu {
                    ForEach(instructors, id: \.self) { instructor in
                        Button(instructor) { selectedInstructor = instructor }
                    }
                } label: {
                    HStack {
                        Text(selectedInstructor)
                            .foregroundColor(.black)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1))
                }
            }
            .padding()
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Godzina rozpoczęcia")
                    .font(.subheadline)

                HStack(spacing: 0) {
                    Picker("", selection: $startHour) {
                        ForEach(hours, id: \.self) {
                            Text(String(format: "%02d", $0))
                                .font(.body)
                        }
                    }
                    Picker("", selection: $startMinute) {
                        ForEach(minutes, id: \.self) {
                            Text(String(format: "%02d", $0))
                                .font(.body)
                        }
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 100)
                .clipped()
            }
            .padding()
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Godzina zakończenia")
                    .font(.subheadline)

                HStack(spacing: 0) {
                    Picker("", selection: $endHour) {
                        ForEach(hours, id: \.self) {
                            Text(String(format: "%02d", $0))
                                .font(.body)
                        }
                    }
                    Picker("", selection: $endMinute) {
                        ForEach(minutes, id: \.self) {
                            Text(String(format: "%02d", $0))
                                .font(.body)
                        }
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 100)
                .clipped()
            }
            .padding()
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )

            Button("Zamknij") {
                withAnimation {
                    showPopup = false
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 24)
            .background(Color.blue.opacity(0.9))
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding(20)
        .frame(maxWidth: 280)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(radius: 10)
    }
}

#Preview {
    KiteReservationView(showPopup: .constant(true),
                        kite: DBKite(id: "demo", name: "Demo", imageName: "demo", state: .free, dateCreated: nil))
}
