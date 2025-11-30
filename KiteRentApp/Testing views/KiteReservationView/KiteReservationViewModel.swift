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
    @Published var didCreateReservation: Bool = false
    @Published var createdRentalId: String?

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
            
            if selectedInstructorId == nil {
                selectedInstructorId = instructors.first?.instructorId
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func confirmReservation(kiteId: String, instructorId: String?, startTime: Date, endTime: Date) async {
        guard !isLoading else { return }
        errorMessage = nil
        didCreateReservation = false
        createdRentalId = nil

        guard let instructorId = instructorId else {
            errorMessage = "Wybierz instruktora."
            return
        }
        guard endTime > startTime else {
            errorMessage = "Czas zakończenia musi być po czasie rozpoczęcia."
            return
        }

        isLoading = true
        defer { isLoading = false }

        let rentalId = UUID().uuidString
        let rental = DBRental(
            rentalId: rentalId,
            kiteId: kiteId,
            instructorId: instructorId,
            startTime: startTime,
            endTime: endTime
        )

        do {
            try await RentalManager.shared.createNewRental(rental: rental)
            self.createdRentalId = rentalId
            self.didCreateReservation = true
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
