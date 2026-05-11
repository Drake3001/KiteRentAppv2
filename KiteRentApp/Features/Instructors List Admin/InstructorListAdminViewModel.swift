//
//  InstructorListAdminViewModel.swift
//  KiteRentApp
//
//  Created by Filip on 11/12/2025.
//

import Foundation
import Combine


@MainActor
final class InstructorListAdminViewModel: ObservableObject {
    @Published var instructors: [DBInstructor] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isSortAscending: Bool = true

    /// Hoisted admin tab VM: skip redundant fetch when returning to the Instructors tab.
    private(set) var adminInstructorListInitialLoadFinished = false

    private let instructorManager: InstructorManagerProtocol

    init(instructorManager: InstructorManagerProtocol? = nil) {
        self.instructorManager = instructorManager ?? InstructorManager.shared
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

    /// Used when the view model is owned by `ProfileView` so tab switches do not re-fetch every time.
    func loadInstructorsForAdminListIfNeeded() async {
        guard !adminInstructorListInitialLoadFinished else { return }
        await loadInstructors()
        if errorMessage == nil {
            adminInstructorListInitialLoadFinished = true
        }
    }

    var filteredAndOrderedInstructors: [DBInstructor] {
        let base: [DBInstructor]
        if searchText.isEmpty {
            base = instructors
        } else {
            base = instructors.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.surname.localizedStandardContains(searchText)}
        }
        
        let nameSorted: [DBInstructor]
        if isSortAscending {
            nameSorted = base.sorted { $0.shortName < $1.shortName }
        } else {
            nameSorted = base.sorted { $0.shortName > $1.shortName }
        }
        
        return nameSorted.sorted { $0.state < $1.state }
    }
}
