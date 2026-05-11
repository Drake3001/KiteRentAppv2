//
//  KiteListAdminView.swift
//  KiteRentApp
//
//  Created by Filip on 09/12/2025.
//

import SwiftUI

struct KiteListAdminView: View {
    @ObservedObject var viewModel: KitesurfingListViewModel
    @StateObject private var deleteViewModel = AdminKiteDeleteViewModel()

    @State private var selectedKiteForEditing: DBKite? = nil

    @State private var kiteToDelete: DBKite? = nil
    @State private var showingDeleteAlert: Bool = false
    @State private var isShowingAddKite: Bool = false

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                SearchBarView(text: $viewModel.searchText)
                    .focused($isSearchFocused)

                FilterRowView(
                    numberOfElements: viewModel.filteredAndOrderedKites.count,
                    onSortTapped: { viewModel.isSortAscending.toggle() },
                    isAscending: viewModel.isSortAscending
                )

                addKiteButton

                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(viewModel.filteredAndOrderedKites) { kite in
                            KiteAdminView(
                                kite: kite,
                                mediaRefreshToken: viewModel.mediaRefreshToken,
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
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                    .frame(maxWidth: .infinity)
                }
                .scrollDismissesKeyboard(.immediately)
                .scrollIndicators(.hidden)
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
            await viewModel.loadKitesForAdminListIfNeeded()
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
        .sheet(isPresented: $isShowingAddKite) {
            Task { await viewModel.loadKites() }
        } content: {
            NavigationStack {
                AdminKiteCreateView()
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

    private var addKiteButton: some View {
        Button {
            isShowingAddKite = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.body.weight(.semibold))
                Text("Add Kite")
                    .font(.subheadline.weight(.semibold))
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .foregroundStyle(.primary)
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.regularMaterial)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.38),
                                Color.white.opacity(0.08),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: Color.black.opacity(0.12), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }

    private func performDeletion(kite: DBKite) async {
        guard let kiteId = kite.id else { return }
        let didDelete = await deleteViewModel.deleteKite(kiteId: kiteId)
        if didDelete {
            await viewModel.loadKites()
        }
    }
}

private struct KiteListAdminViewPreviewHost: View {
    @StateObject private var viewModel = KitesurfingListViewModel()

    var body: some View {
        ZStack {
            AdminGlassBackground()
            KiteListAdminView(viewModel: viewModel)
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    KiteListAdminViewPreviewHost()
}
