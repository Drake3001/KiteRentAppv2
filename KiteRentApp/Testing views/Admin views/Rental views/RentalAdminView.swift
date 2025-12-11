//
//  RentalAdminView.swift
//  KiteRentApp
//
//  Created by Filip on 11/12/2025.
//

import SwiftUI

struct RentalAdminView: View {
    var rental: DBRental
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(rental.kiteId)
                    .font(.title)
                    .fontWeight(.bold)
                    .lineLimit(1)
                
                Text(rental.instructorId)
                    .font(.headline)
                    .lineLimit(1)
                
                
                HStack {
                    HStack {
                        Image(systemName: "calendar")
                        Text(rental.startTime.formatted(
                            .dateTime.day(.defaultDigits)
                            .month(.twoDigits)
                            .year()
                            .locale(Locale(identifier: "pl_PL"))
                        ))
                    }
                    
                    Spacer()
                    
                    HStack {
                        Image(systemName: "clock")
                        Text("\(rental.startTime.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))) - \(rental.endTime.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits)))")
                    }
                    
                    let diff = Calendar.current.dateComponents([.hour, .minute], from: rental.startTime, to: rental.endTime)
                    
                    Spacer()
                    
                    Text("\(diff.hour ?? 0)h \(diff.minute ?? 0)m")
                }
                .font(.subheadline)
                .foregroundStyle(Color(.secondaryLabel))
                
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 4)
            
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    RentalAdminView(rental: DBRental(rentalId: "1234", kiteId: "kite1", instructorId: "instructor1", startTime: Date(), endTime: Date()))
}
