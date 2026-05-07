//
//  InstructorRentalCard.swift
//  KiteRentApp
//
//  Created by Vilstig on 07/05/2026.
//
import SwiftUI

struct InstructorRentalCard: View {
    let rental: InstructorRental
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(rental.kiteName)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(1)

            HStack {
                HStack {
                    Image(systemName: "clock")
                    Text("\(rental.startTime.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))) - \(rental.endTime.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits)))")
                }

                Spacer()

                let diff = Calendar.current.dateComponents([.hour, .minute], from: rental.startTime, to: rental.endTime)
                Text("\(diff.hour ?? 0)h \(diff.minute ?? 0)m")
            }
            .font(.subheadline)
            .foregroundStyle(Color(.secondaryLabel))
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.primary.opacity(colorScheme == .dark ? 0.15 : 0.05), radius: 2, y: 4)
        .frame(maxWidth: .infinity)
    }
}
