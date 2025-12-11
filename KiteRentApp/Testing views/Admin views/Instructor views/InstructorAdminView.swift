//
//  InstructorAdminView.swift
//  KiteRentApp
//
//  Created by Filip on 11/12/2025.
//

import SwiftUI

struct InstructorAdminView: View {
    var instructor: DBInstructor
    
    var body: some View {
        ZStack {
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 50))
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(instructor.name + " " + instructor.surname)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(1)
                    
                    TagView(text: textFromState(state: instructor.state), backgroundColor: colorFromState(state: instructor.state))
                }
                
                Spacer()
                
                Image(systemName: "pencil")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .font(.title)
                    .fontWeight(.bold)
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color.black.opacity(0.05), radius: 2, y: 4)
        }
        .frame(maxWidth: .infinity)
    }
    
    func textFromState(state: InstructorState) -> String {
        switch state {
        case .active:
            return "Aktywny"
        case .inactive:
            return "Nieaktwyny"
        }
    }
    
    func colorFromState(state: InstructorState) -> Color {
        switch state {
        case .active:
            return .green
        case .inactive:
            return .red
        }
    }
}

#Preview {
    InstructorAdminView(instructor: DBInstructor(instructorId: "123", name: "John", surname: "Smith", phoneNumber: "123456789", dateCreated: Date.now, state: .active))
}
