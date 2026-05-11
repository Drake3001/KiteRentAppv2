//
//  RentalListAdminView.swift
//  KiteRentApp
//
//  Created by Filip on 11/12/2025.
//

import SwiftUI

struct RentalListAdminView: View {
    @ObservedObject var viewModel: RentalListAdminViewModel

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                SearchBarView(text: $viewModel.searchText)
                    .focused($isSearchFocused)

                FilterRowAdminView(
                    selectedDate: $viewModel.selectedDate,
                    numberOfElements: viewModel.filteredAndOrderedRentals.count,
                    onSortTapped: { viewModel.isSortAscending.toggle() },
                    isAscending: viewModel.isSortAscending
                )

                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(viewModel.filteredAndOrderedRentals) { rental in
                            RentalAdminView(rental: rental)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.immediately)
                .scrollIndicators(.hidden)
                .background(Color.clear)
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
        .background(Color.clear)
        .task {
            await viewModel.initRentalsForAdminListIfNeeded()
        }
        .refreshable {
            await viewModel.initRentals()
        }
    }
}

private struct RentalListAdminViewPreviewHost: View {
    @StateObject private var viewModel = RentalListAdminViewModel()

    var body: some View {
        ZStack {
            AdminGlassBackground()
            RentalListAdminView(viewModel: viewModel)
        }
    }
}

#Preview {
    RentalListAdminViewPreviewHost()
}
