import Foundation

enum ReservationInstructorMode: Equatable {
    case selectable
    case fixed(DBInstructor)

    static func == (lhs: ReservationInstructorMode, rhs: ReservationInstructorMode) -> Bool {
        switch (lhs, rhs) {
        case (.selectable, .selectable):
            return true
        case (.fixed(let a), .fixed(let b)):
            return a.instructorId == b.instructorId
        default:
            return false
        }
    }
}

