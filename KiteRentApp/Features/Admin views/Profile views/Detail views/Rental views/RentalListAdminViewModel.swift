//
//  RentalListAdminViewModel.swift
//  KiteRentApp
//
//  Created by Filip on 11/12/2025.
//

import Foundation
import Combine

@MainActor
final class RentalListAdminViewModel: ObservableObject {
    @Published var rentals: [AdminRental] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedDate: Date? = Calendar.current.startOfDay(for: Date())
    @Published var isSortAscending: Bool = false

    private let rentalManager: RentalManagerProtocol
    private let instructorManager: InstructorManagerProtocol
    private let kiteManager: KiteManagerProtocol
    
    private var fetchedRentals: [DBRental] = []
    private var kites: [DBKite] = []
    private var instructors: [DBInstructor] = []

    init(
        rentalManager: RentalManagerProtocol? = nil,
        instructorManager: InstructorManagerProtocol? = nil,
        kiteManager: KiteManagerProtocol? = nil
    ) {
        self.rentalManager = rentalManager ?? RentalManager.shared
        self.instructorManager = instructorManager ?? InstructorManager.shared
        self.kiteManager = kiteManager ?? KiteManager.shared
    }
    
    var filteredAndOrderedRentals: [AdminRental] {
        let base: [AdminRental] = rentals
        let dateFilteredRentals: [AdminRental]
        let calendar = Calendar.current
        
        if let filterDate = selectedDate {
            dateFilteredRentals = base.filter { rental in
                return calendar.isDate(rental.startTime, inSameDayAs: filterDate)
            }
        } else {
            dateFilteredRentals = base
        }
        
        let textFilteredRentals: [AdminRental]
        
        if searchText.isEmpty {
            textFilteredRentals = dateFilteredRentals
        } else {
            textFilteredRentals = dateFilteredRentals.filter { $0.instructorName.localizedCaseInsensitiveContains(searchText) || $0.kiteName.localizedCaseInsensitiveContains(searchText)}
        }
        
        let startTimeSorted: [AdminRental]
        if isSortAscending {
            startTimeSorted = textFilteredRentals.sorted { $0.startTime < $1.startTime }
        } else {
            startTimeSorted = textFilteredRentals.sorted { $0.startTime > $1.startTime }
        }
        
        return startTimeSorted
    }
    
    func initRentals() async {
        await loadRentals()
        await loadKites()
        await loadInstructors()
        
        let computedRentals =  await computeRentals(rentals: fetchedRentals)
        self.rentals = computedRentals
    }
    
    func loadRentals() async {
        guard !isLoading else {return}
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await rentalManager.getAllRentals()
            self.fetchedRentals = fetched
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
        
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
    
    func loadKites() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await kiteManager.getAllKites()
            self.kites = fetched
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func computeRentals(rentals: [DBRental]) async -> [AdminRental] {
        let kiteMap = Dictionary(uniqueKeysWithValues: kites.map { ($0.id, $0.name)})
        let instructorMap = Dictionary(uniqueKeysWithValues: instructors.map { ($0.id, $0.shortName)})
        
        let deletedText = "Data Unavailable"
        
        return rentals.compactMap { rental in
            
            let kiteName = kiteMap[rental.kiteId] ?? deletedText
            let instructorName = instructorMap[rental.instructorId] ?? deletedText
            
            return AdminRental(
                rentalID: rental.id,
                kiteName: kiteName,
                instructorName: instructorName,
                startTime: rental.startTime,
                endTime: rental.endTime
            )
        }
    }
}

struct AdminRental: Identifiable {
    let rentalID: String
    
    let kiteName: String
    let instructorName: String
    
    let startTime: Date
    let endTime: Date
    
    var id: String { rentalID }
}


