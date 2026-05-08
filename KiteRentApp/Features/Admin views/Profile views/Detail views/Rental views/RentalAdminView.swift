//
//  RentalAdminView.swift
//  KiteRentApp
//
//  Created by Filip on 11/12/2025.
//

import SwiftUI

struct RentalAdminView: View {
    var rental: AdminRental

    var body: some View {
        GlassCard(cornerRadius: 22, material: .thinMaterial, contentPadding: 14) {
            VStack(alignment: .leading, spacing: 10) {
                Text(rental.kiteName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .lineLimit(1)

                Text(rental.instructorName)
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "calendar")
                        Text(
                            rental.startTime.formatted(
                                .dateTime.day(.defaultDigits)
                                    .month(.twoDigits)
                                    .year()
                                    .locale(Locale(identifier: "pl_PL"))
                            )
                        )
                    }

                    Spacer()

                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                        Text(
                            "\(rental.startTime.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))) - \(rental.endTime.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits)))"
                        )
                    }

                    Spacer()

                    Text(durationLabel)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var durationLabel: String {
        let diff = Calendar.current.dateComponents([.hour, .minute], from: rental.startTime, to: rental.endTime)
        return "\(diff.hour ?? 0)h \(diff.minute ?? 0)m"
    }
}

#Preview {
    ZStack {
        AdminGlassBackground()
        RentalAdminView(rental: AdminRental(rentalID: "1234", kiteName: "North Reach", instructorName: "John Smith", startTime: Date(), endTime: Date()))
            .padding()
    }
}
