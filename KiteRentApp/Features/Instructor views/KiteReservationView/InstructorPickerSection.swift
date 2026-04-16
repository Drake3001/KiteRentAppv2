//
//  InstructorPickerSection.swift
//  KiteRentApp
//
//  Created by Filip on 29/11/2025.
//
import SwiftUI

struct InstructorPickerSection: View {
    let instructors: [DBInstructor]
    @Binding var selectedInstructor: DBInstructor?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Instruktor")
                .font(.subheadline)
            
            Menu {
                ForEach(instructors) { instructor in
                    Button(instructor.shortName) {
                        selectedInstructor = instructor
                    }
                }
            } label: {
                HStack {
                    Text(selectedInstructor?.shortName ?? "Wybierz instruktora")
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
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding()
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}
