//
//  InstructorListAdminView.swift
//  KiteRentApp
//
//  Created by Filip on 11/12/2025.
//

import SwiftUI

struct InstructorListAdminView: View {
    @StateObject private var viewModel = InstructorListAdminViewModel()
    
    @State private var selectedInstructorForEditing: DBInstructor? = nil
    
    var body: some View {
        SearchBarView(text: $viewModel.searchText)
        
        Spacer()
        
        FilterRowView(
            numberOfElements: viewModel.filteredAndOrderedInstructors.count,
            onSortTapped: {viewModel.isSortAscending.toggle()},
            isAscending: viewModel.isSortAscending
        )
        
        Spacer()
        
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.filteredAndOrderedInstructors) { instructor in
                    InstructorAdminView(instructor: instructor) { instructor in
                        self.selectedInstructorForEditing = instructor
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(Color("LightGrayBackgroundColor"))
        .task {
            await viewModel.loadInstructors()
          
        }
        .refreshable { await viewModel.loadInstructors() }
        .sheet(item: $selectedInstructorForEditing) {
            Task { await viewModel.loadInstructors() }
        } content: { instructorToEdit in
            NavigationStack {
                InstructorEditView(instructor: instructorToEdit)
            }
        }
    }
}

#Preview {
    InstructorListAdminView()
}
