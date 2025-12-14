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

    func loadInstructors() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await InstructorManager.shared.getAllInstructors()
            self.instructors = fetched
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
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
