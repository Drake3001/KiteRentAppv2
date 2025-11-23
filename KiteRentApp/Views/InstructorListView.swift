//
//  InstructorListView.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 23/11/2025.
//

import SwiftUI
import Foundation
import Combine

@MainActor
class InstructorListViewModel: ObservableObject {
    
    @Published var instructorsText: String = ""
    
    func loadInstructors() async {
        do {
            let instructors = try await InstructorManager.shared.getAllInstructors()
            
            instructorsText = instructors.map { instructor in
                """
                ID: \(instructor.instructorId)
                Imię: \(instructor.name)
                Nazwisko: \(instructor.surname)
                Phone number: \(instructor.phoneNumber ?? "-")
                
                """
            }.joined(separator: "----------------\n")
            
        } catch {
            instructorsText = "Błąd: \(error.localizedDescription)"
        }
    }
}

import SwiftUI

struct InstructorListView: View {
    @StateObject private var viewModel = InstructorListViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.instructorsText.isEmpty {
                    Text("Ładowanie...")
                        .padding()
                } else {
                    Text(viewModel.instructorsText)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .navigationTitle("Wszyscy Instruktorzy")
        }
        .task {
            await viewModel.loadInstructors()
        }
    }
}

