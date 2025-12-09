//
//  KiteListAdminView.swift
//  KiteRentApp
//
//  Created by Filip on 09/12/2025.
//

import SwiftUI

struct KiteListAdminView: View {
    @StateObject private var viewModel = KiteListAdminViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(viewModel.filteredAndOrderedKites) { kite in
                    KiteAdmin(kite: kite)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .task{
            await viewModel.loadKites()
            viewModel.startRefreshOnRentalEnd()
        }
        .refreshable { await viewModel.loadKites() }
    }
}

#Preview {
    KiteListAdminView()
}
