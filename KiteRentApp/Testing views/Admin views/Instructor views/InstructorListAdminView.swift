//
//  InstructorListAdminView.swift
//  KiteRentApp
//
//  Created by Filip on 11/12/2025.
//

import SwiftUI

struct InstructorListAdminView: View {
    @StateObject private var viewModel = InstructorListAdminViewModel()
    
    var body: some View {
        SearchBarView(text: $viewModel.searchText)
        
        Spacer()
        
        FilterRowView(
            numberOfKites: viewModel.filteredAndOrderedInstructors.count,
            onSortTapped: {viewModel.isSortAscending.toggle()},
            isAscending: viewModel.isSortAscending
        )
        
        Spacer()
        
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.filteredAndOrderedInstructors) { instructor in
                    InstructorAdminView(instructor: instructor)
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
    }
}

#Preview {
    InstructorListAdminView()
}
