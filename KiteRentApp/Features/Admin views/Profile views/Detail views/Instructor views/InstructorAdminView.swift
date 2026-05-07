//
//  InstructorAdminView.swift
//  KiteRentApp
//
//  Created by Filip on 11/12/2025.
//

import SwiftUI

struct InstructorAdminView: View {
    var instructor: DBInstructor

    var onEditTapped: (DBInstructor) -> Void

    var body: some View {
        GlassCard(cornerRadius: 22, material: .thinMaterial, contentPadding: 14) {
            HStack(alignment: .center, spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 64, height: 64)
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.22), lineWidth: 1)
                        }

                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(instructor.name + " " + instructor.surname)
                        .font(.title3)
                        .fontWeight(.bold)
                        .lineLimit(1)

                    TagView(text: textFromState(state: instructor.state), backgroundColor: colorFromState(state: instructor.state))
                }

                Spacer(minLength: 8)

                Button {
                    onEditTapped(instructor)
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
    }

    func textFromState(state: InstructorState) -> String {
        switch state {
        case .active:
            return "Aktywny"
        case .inactive:
            return "Nieaktywny"
        }
    }

    func colorFromState(state: InstructorState) -> Color {
        switch state {
        case .active:
            return .green
        case .inactive:
            return .red.opacity(0.8)
        }
    }
}

#Preview {
    ZStack {
        AdminGlassBackground()
        InstructorAdminView(instructor: DBInstructor(instructorId: "123", name: "John", surname: "Smith", phoneNumber: "123456789", dateCreated: Date.now, state: .inactive), onEditTapped: { _ in })
            .padding()
    }
}
