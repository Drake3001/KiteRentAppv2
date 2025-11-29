//
//  KiteReservationViewModel.swift
//  KiteRentApp
//
//  Created by Filip on 29/11/2025.
//
import Foundation
import Combine


@MainActor
final class KiteReservationViewModel: ObservableObject {
    @Published var instructors: [DBInstructor] = []
    @Published var selectedInstructorId: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    var selectedInstructorName: String {
        if let id = selectedInstructorId, let instr = instructors.first(where: { $0.instructorId == id }) {
            return "\(instr.name) \(instr.surname)"
        }
        return "Wybierz instruktora"
    }

    func loadInstructors() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await InstructorManager.shared.getAllInstructors()
            self.instructors = fetched
            // Ustaw domyślny wybór (opcjonalnie pierwszy na liście)
            if selectedInstructorId == nil {
                selectedInstructorId = instructors.first?.shortName
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
