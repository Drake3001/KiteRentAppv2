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
    @Published var selectedInstructor: DBInstructor?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var didCreateReservation: Bool = false
    @Published var createdRentalId: String?

    @Published var startHour: Int
    @Published var startMinute: Int
    @Published var endHour: Int
    @Published var endMinute: Int

    let maxHour: Int
    let maxMinute: Int

    let startHours: [Int]
    let endHours: [Int]
    let endMinutes: [Int]

    private let kiteManager: KiteManagerProtocol
    private let rentalManager: RentalManagerProtocol
    private let instructorManager: InstructorManagerProtocol

    var filteredInstructors: [DBInstructor] {
        return instructors.filter { $0.state == .active }
    }

    var selectedInstructorId: String? {
        selectedInstructor?.instructorId
    }

    var startMinutes: [Int] {
        getValidMinutes(for: startHour)
    }

    var isConfirmDisabled: Bool {
        isLoading || startTime > endTime
    }

    var startTime: Date {
        makeDate(hour: startHour, minute: startMinute)
    }

    var endTime: Date {
        makeDate(hour: endHour, minute: endMinute)
    }

    init(kiteManager: KiteManagerProtocol? = nil,
         rentalManager: RentalManagerProtocol? = nil,
         instructorManager: InstructorManagerProtocol? = nil) {
        self.kiteManager = kiteManager ?? KiteManager.shared
        self.rentalManager = rentalManager ?? RentalManager.shared
        self.instructorManager = instructorManager ?? InstructorManager.shared

        let times = Self.initTime()
        self.startHour = times.startHour
        self.startMinute = times.startMinute
        self.endHour = times.endHour
        self.endMinute = times.endMinute
        self.maxHour = times.startHour
        self.maxMinute = times.startMinute
        self.startHours = Array(AppConstants.defaultWorkStartHour ..< times.startHour + 1)
        self.endHours = Array(AppConstants.defaultWorkStartHour ..< AppConstants.defaultWorkEndHour + 1)
        self.endMinutes = Array(stride(from: 0, through: 55, by: 15))
    }

    func getValidMinutes(for hour: Int) -> [Int] {
        if hour < maxHour {
            return Array(stride(from: 0, through: 55, by: 15))
        } else if hour == maxHour {
            return Array(stride(from: 0, through: maxMinute, by: 15))
        } else {
            return []
        }
    }

    func clampStartMinuteIfNeeded() {
        let validMinutes = getValidMinutes(for: startHour)
        if !validMinutes.contains(startMinute) {
            startMinute = validMinutes.last ?? 0
        }
    }

    func loadInstructors() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await instructorManager.getAllInstructors()
            self.instructors = fetched
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func confirmReservation(kiteId: String) async {
        guard !isLoading else { return }
        errorMessage = nil
        didCreateReservation = false
        createdRentalId = nil

        guard let instructorId = selectedInstructorId else {
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
            try await rentalManager.createNewRental(rental: rental)
            try await kiteManager.updateKiteState(kiteId: kiteId, state: .used)

            self.createdRentalId = rentalId
            self.didCreateReservation = true
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }

    private func makeDate(hour: Int, minute: Int) -> Date {
        var comps = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        comps.hour = hour
        comps.minute = minute
        return Calendar.current.date(from: comps) ?? Date()
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
        
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        
        let prevQuarter = (minute / 15) * 15
        
        let startMinute = prevQuarter
        let startHour = hour
                
        var startComps = calendar.dateComponents([.year, .month, .day], from: now)
        startComps.hour = startHour
        startComps.minute = startMinute
        var startDate = calendar.date(from: startComps)!
        startDate = clampToWorkHours(startDate, isStartDate: true)
        
        var endDate = calendar.date(byAdding: .hour,
                                    value: AppConstants.defaultLessonDurationHours,
                                    to: startDate)!
        endDate = calendar.date(byAdding: .minute,
                                value: AppConstants.defaultLessonDurationMinutes,
                                to: endDate)!
        endDate = clampToWorkHours(endDate, isStartDate: false)
        
        let endHour = calendar.component(.hour, from: endDate)
        let endMinute = calendar.component(.minute, from: endDate)
        
        return (startHour: calendar.component(.hour, from: startDate),
                startMinute: calendar.component(.minute, from: startDate),
                endHour: endHour,
                endMinute: endMinute)
    }
    
    static func clampToWorkHours(_ date: Date, isStartDate: Bool) -> Date {
        let calendar = Calendar.current
        
        let workStart = AppConstants.defaultWorkStartHour
        let workEnd = AppConstants.defaultWorkEndHour
        
        var comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        if comps.hour! < workStart {
            comps.hour = (isStartDate ? workStart : workEnd)
            comps.minute = 0
        }
        
        if comps.hour! >= workEnd {
            comps.hour = workEnd
            comps.minute = 0
        }
        
        return calendar.date(from: comps) ?? date
    }
}
