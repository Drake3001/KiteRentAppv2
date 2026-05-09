import Foundation
import Combine

@MainActor
final class EditRentalEndTimeViewModel: ObservableObject {
    let rental: InstructorRental

    @Published var endHour: Int
    @Published var endMinute: Int
    @Published var errorMessage: String?

    private let stepMinutes: Int = 15
    private let workStartHour: Int = AppConstants.defaultWorkStartHour
    private let workEndHour: Int = AppConstants.defaultWorkEndHour

    /// Minimum selectable time based on current time, rounded up to next 15-minute boundary
    /// and clamped into working hours.
    private var minSelectable: (hour: Int, minute: Int) {
        let calendar = Calendar.current
        let now = Date()

        var comps = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: now)
        let hour = comps.hour ?? workStartHour
        let minute = comps.minute ?? 0

        var roundedHour = hour
        var roundedMinute = ((minute + (stepMinutes - 1)) / stepMinutes) * stepMinutes
        if roundedMinute >= 60 {
            roundedMinute = 0
            roundedHour += 1
        }

        // Clamp into work hours.
        if roundedHour < workStartHour {
            roundedHour = workStartHour
            roundedMinute = 0
        }
        if roundedHour > workEndHour {
            roundedHour = workEndHour
            roundedMinute = 0
        }

        comps.hour = roundedHour
        comps.minute = roundedMinute
        let clamped = calendar.date(from: comps) ?? now

        let out = calendar.dateComponents([.hour, .minute], from: clamped)
        return (out.hour ?? workStartHour, out.minute ?? 0)
    }

    var hours: [Int] {
        let minH = minSelectable.hour
        guard minH <= workEndHour else { return [workEndHour] }
        return Array(minH ... workEndHour)
    }

    init(rental: InstructorRental) {
        self.rental = rental

        let calendar = Calendar.current
        let comps = calendar.dateComponents([.hour, .minute], from: rental.endTime)
        let hour = comps.hour ?? workStartHour
        let minute = comps.minute ?? 0
        let roundedMinute = (minute / stepMinutes) * stepMinutes

        self.endHour = hour
        self.endMinute = roundedMinute
        self.errorMessage = nil

        // Clamp selection so it doesn't allow times before "now".
        let min = minSelectable
        if endHour < min.hour || (endHour == min.hour && endMinute < min.minute) {
            endHour = min.hour
            endMinute = min.minute
        }
    }

    func validMinutes(for hour: Int) -> [Int] {
        let min = minSelectable

        if hour < min.hour { return [] }
        if hour == min.hour {
            let start = min.minute
            return Array(stride(from: start, through: 55, by: stepMinutes))
        }
        return Array(stride(from: 0, through: 55, by: stepMinutes))
    }

    func clampMinuteIfNeeded() {
        let valid = validMinutes(for: endHour)
        if !valid.contains(endMinute) {
            endMinute = valid.first ?? 0
        }
    }

    func makeSelectedEndTime() -> Date {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.year, .month, .day], from: rental.endTime)
        comps.hour = endHour
        comps.minute = endMinute
        return calendar.date(from: comps) ?? rental.endTime
    }

    func validate() -> Date? {
        errorMessage = nil
        let newEndTime = makeSelectedEndTime()
        guard newEndTime > rental.startTime else {
            errorMessage = "End time must be after start time."
            return nil
        }
        return newEndTime
    }
}

