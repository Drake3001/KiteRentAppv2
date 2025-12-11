//
//  RentalListAdminView.swift
//  KiteRentApp
//
//  Created by Filip on 11/12/2025.
//

import SwiftUI

struct RentalListAdminView: View {
    @StateObject private var viewModel = RentalListAdminViewModel()
    
    var body: some View {
        SearchBarView(text: $viewModel.searchText)
        
        Spacer()
        
        FilterRowAdminView(
            selectedDate: $viewModel.selectedDate,
            numberOfElements: viewModel.filteredAndOrderedRentals.count,
            onSortTapped: {viewModel.isSortAscending.toggle()},
            isAscending: viewModel.isSortAscending
        )
        
        Spacer()
        
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.filteredAndOrderedRentals) { rental in
                    RentalAdminView(rental: rental)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(Color("LightGrayBackgroundColor"))
        .task {
            await viewModel.initRentals()
        }
        .refreshable { await viewModel.initRentals() }
    }
}

#Preview {
    RentalListAdminView()
}
