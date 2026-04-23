//
//  KiteListAdminView.swift
//  KiteRentApp
//
//  Created by Filip on 09/12/2025.
//

import SwiftUI

struct KiteListAdminView: View {
    @StateObject private var viewModel = KitesurfingListViewModel()
    @StateObject private var deleteViewModel = AdminKiteDeleteViewModel()

    @State private var selectedKiteForEditing: DBKite? = nil

    @State private var kiteToDelete: DBKite? = nil
    @State private var showingDeleteAlert: Bool = false

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ZStack {
            VStack {
                SearchBarView(text: $viewModel.searchText)
                    .focused($isSearchFocused)

                Spacer()

                FilterRowView(
                    numberOfElements: viewModel.filteredAndOrderedKites.count,
                    onSortTapped: { viewModel.isSortAscending.toggle() },
                    isAscending: viewModel.isSortAscending
                )

                Spacer()

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.filteredAndOrderedKites) { kite in
                            KiteAdminView(
                                kite: kite,
                                onEditTapped: { selectedKite in
                                    selectedKiteForEditing = selectedKite
                                },
                                onDeleteTapped: { selectedKite in
                                    kiteToDelete = selectedKite
                                    showingDeleteAlert = true
                                }
                            )
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.immediately)
                .background(Color(.systemGroupedBackground))
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
            await viewModel.loadKites()
        }
        .refreshable {
            await viewModel.loadKites()
        }
        .sheet(item: $selectedKiteForEditing) {
            Task { await viewModel.loadKites() }
        } content: { kiteToEdit in
            NavigationStack {
                KiteEditView(kite: kiteToEdit)
            }
        }
        .alert("Confirm Deletion", isPresented: $showingDeleteAlert, presenting: kiteToDelete) { kite in
            Button("Delete Kite", role: .destructive) {
                Task { await performDeletion(kite: kite) }
            }
            Button("Cancel", role: .cancel) { }
        } message: { _ in
            Text("This action cannot be undone. All associated rental history for this kite will be lost.")
        }
        .alert("Error", isPresented: $deleteViewModel.showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(deleteViewModel.errorMessage)
        }
    }

    private func performDeletion(kite: DBKite) async {
        guard let kiteId = kite.id else { return }
        let didDelete = await deleteViewModel.deleteKite(kiteId: kiteId)
        if didDelete {
            await viewModel.loadKites()
        }
    }
}

#Preview {
    KiteListAdminView()
        .preferredColorScheme(.dark)
}
