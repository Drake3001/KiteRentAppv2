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
            // Tworzenie rezerwacji
            try await RentalManager.shared.createNewRental(rental: rental)
            
            // Zmiana statusu kite z free na used
            try await KiteManager.shared.updateKiteState(kiteId: kiteId, state: .used)
            
            self.createdRentalId = rentalId
            self.didCreateReservation = true
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    
}

extension KiteReservationViewModel {

    /// Returns rounded start time based on current date + computed end time.
    /// Uses AppConstants for working hours and default lesson duration.
    static func initTime()
    -> (startHour: Int, startMinute: Int, endHour: Int, endMinute: Int)
    {
        let calendar = Calendar.current
        let now = Date()
        
        // --- 1. Round start minutes according to custom rules ---
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        
        let prevQuarter = (minute / 15) * 15
        
        
        let startMinute = prevQuarter
        let startHour = hour
                
        // --- 2. Build start date and clamp to work hours ---
        var startComps = calendar.dateComponents([.year, .month, .day], from: now)
        startComps.hour = startHour
        startComps.minute = startMinute
        var startDate = calendar.date(from: startComps)!
        startDate = clampToWorkHours(startDate)
        
        // --- 3. Compute end date by adding lesson duration ---
        var endDate = calendar.date(byAdding: .hour,
                                    value: AppConstants.defaultLessonDurationHours,
                                    to: startDate)!
        endDate = calendar.date(byAdding: .minute,
                                value: AppConstants.defaultLessonDurationMinutes,
                                to: endDate)!
        endDate = clampToWorkHours(endDate)
        
        let endHour = calendar.component(.hour, from: endDate)
        let endMinute = calendar.component(.minute, from: endDate)
        
        return (startHour: calendar.component(.hour, from: startDate),
                startMinute: calendar.component(.minute, from: startDate),
                endHour: endHour,
                endMinute: endMinute)
    }
    
    /// Ensures a date stays within working hours defined by AppConstants.
    static func clampToWorkHours(_ date: Date) -> Date {
        let calendar = Calendar.current
        
        let workStart = AppConstants.defaultWorkStartHour
        let workEnd = AppConstants.defaultWorkEndHour
        
        var comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        if comps.hour! < workStart {
            comps.hour = workStart
            comps.minute = 0
        }
        
        if comps.hour! >= workEnd {
            comps.hour = workEnd
            comps.minute = 0
        }
        
        return calendar.date(from: comps) ?? date
    }
}
