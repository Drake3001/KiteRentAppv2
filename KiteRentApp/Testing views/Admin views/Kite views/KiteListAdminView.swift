//
//  KiteListAdminView.swift
//  KiteRentApp
//
//  Created by Filip on 09/12/2025.
//

import SwiftUI

struct KiteListAdminView: View {
    @StateObject private var viewModel = KitesurfingListViewModel()
    
    var body: some View {
        SearchBarView(text: $viewModel.searchText)
        
        Spacer()
        
        FilterRowView(
            numberOfKites: viewModel.filteredAndOrderedKites.count,
            onSortTapped: {viewModel.isSortAscending.toggle()},
            isAscending: viewModel.isSortAscending
        )
        
        Spacer()
        
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.filteredAndOrderedKites) { kite in
                    KiteAdminView(kite: kite)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(Color("LightGrayBackgroundColor"))
        .task {
            await viewModel.loadKites()
            await viewModel.startRefreshOnRentalEnd()
        }
        .onDisappear {
            Task {
                await viewModel.stopRefreshOnRentalEnd()
            }
        }
        .refreshable { await viewModel.loadKites() }
    }
}

#Preview {
    KiteListAdminView()
}
