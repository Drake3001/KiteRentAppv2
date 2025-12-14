//
//  TimePickerSection.swift
//  KiteRentApp
//
//  Created by Filip on 29/11/2025.
//

import SwiftUI

struct TimePickerSection: View {
    let title: String
    let hours: [Int]
    let minutes: [Int]
    
    @Binding var hour: Int
    @Binding var minute: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
            
            HStack(spacing: 0) {
                Picker("", selection: $hour) {
                    ForEach(hours, id: \.self) {
                        Text(String(format: "%02d", $0))
                            .font(.body)
                    }
                }
                Picker("", selection: $minute) {
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
    }
}
