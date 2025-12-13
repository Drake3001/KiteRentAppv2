//
//  RentalListAdminView.swift
//  KiteRentApp
//
//  Created by Filip on 11/12/2025.
//

import SwiftUI

struct RentalListAdminView: View {
    @StateObject private var viewModel = RentalListAdminViewModel()

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ZStack {
            VStack {
                SearchBarView(text: $viewModel.searchText)
                    .focused($isSearchFocused)

                Spacer()

                FilterRowAdminView(
                    selectedDate: $viewModel.selectedDate,
                    numberOfElements: viewModel.filteredAndOrderedRentals.count,
                    onSortTapped: { viewModel.isSortAscending.toggle() },
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
                .scrollDismissesKeyboard(.immediately)
                .background(Color("LightGrayBackgroundColor"))
            }

            if isSearchFocused {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        isSearchFocused = false
                    }
                    .zIndex(1)
            }
        }
        .task {
            await viewModel.initRentals()
        }
        .refreshable {
            await viewModel.initRentals()
        }
    }
}

#Preview {
    RentalListAdminView()
}
