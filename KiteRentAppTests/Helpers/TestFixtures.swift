//
//  TestFixtures.swift
//  KiteRentAppTests
//

import Foundation
@testable import KiteRentApp

enum TestFixtures {

    /// In-memory test kites must not set `@DocumentID` — Firestore ignores manual IDs and logs warnings.
    static func makeKite(
        name: String = "Alpha",
        imageName: String = "img",
        state: KiteState = .free,
        brand: String = "Brand",
        kiteModel: String = "Model",
        size: String = "9",
        dateCreated: Date? = nil
    ) -> DBKite {
        DBKite(
            id: nil,
            name: name,
            imageName: imageName,
            state: state,
            brand: brand,
            kiteModel: kiteModel,
            size: size,
            dateCreated: dateCreated
        )
    }

    static func makeInstructor(
        id: String = "inst-1",
        name: String = "Jan",
        surname: String = "Kowalski",
        phone: String? = nil,
        state: InstructorState = .active
    ) -> DBInstructor {
        DBInstructor(
            instructorId: id,
            name: name,
            surname: surname,
            phoneNumber: phone,
            dateCreated: Date(),
            state: state
        )
    }

    static func makeRental(
        rentalId: String = "rent-1",
        kiteId: String = "kite-1",
        instructorId: String = "inst-1",
        start: Date,
        end: Date
    ) -> DBRental {
        DBRental(
            rentalId: rentalId,
            kiteId: kiteId,
            instructorId: instructorId,
            startTime: start,
            endTime: end
        )
    }

    static func makeUser(
        userId: String = "user-1",
        email: String? = "a@b.c",
        role: UserRole = .instructor
    ) -> DBUser {
        DBUser(userId: userId, email: email, dateCreated: Date(), role: role)
    }
}
