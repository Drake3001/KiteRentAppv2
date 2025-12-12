//
//  KiteListAdminView.swift
//  KiteRentApp
//
//  Created by Filip on 09/12/2025.
//

import SwiftUI

struct KiteListAdminView: View {
    @StateObject private var viewModel = KitesurfingListViewModel()
    
    @State private var selectedKiteForEditing: DBKite? = nil
    
    @State private var kiteToDelete: DBKite? = nil
    @State private var showingDeleteAlert: Bool = false
    
    var body: some View {
        SearchBarView(text: $viewModel.searchText)
        
        Spacer()
        
        FilterRowView(
            numberOfElements: viewModel.filteredAndOrderedKites.count,
            onSortTapped: {viewModel.isSortAscending.toggle()},
            isAscending: viewModel.isSortAscending
        )
        
        Spacer()
        
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.filteredAndOrderedKites) { kite in
                    KiteAdminView(
                        kite: kite,
                        onEditTapped: { selectedKite in
                            self.selectedKiteForEditing = selectedKite
                        },
                        onDeleteTapped: { selectedKite in
                            self.kiteToDelete = selectedKite
                            self.showingDeleteAlert = true
                        }
                    )
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .background(Color("LightGrayBackgroundColor"))
        .task {
            await viewModel.loadKites()
            
        }
        
        .refreshable { await viewModel.loadKites() }
        
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
        } message: { kite in
            Text("This action cannot be undone. All associated rental history for this kite will be lost.")
        }
    }
    
    private func performDeletion(kite: DBKite) async {
        guard let kiteId = kite.id else { return }
        do {
            try await KiteManager.shared.deleteKite(kiteId: kiteId)
            await viewModel.loadKites()
        } catch {
            print("Failed to delete kite: \(error)")
        }
    }
}

#Preview {
    KiteListAdminView()
}
