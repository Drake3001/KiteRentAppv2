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

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ZStack {
            VStack {
                SearchBarView(text: $viewModel.searchText)
                    .focused($isSearchFocused)

                Spacer()

                FilterRowView(
                    numberOfElements: viewModel.filteredAndOrderedInstructors.count,
                    onSortTapped: { viewModel.isSortAscending.toggle() },
                    isAscending: viewModel.isSortAscending
                )

                Spacer()

                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.filteredAndOrderedInstructors) { instructor in
                            InstructorAdminView(instructor: instructor) { instructor in
                                selectedInstructorForEditing = instructor
                            }
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
            await viewModel.loadInstructors()
        }
        .refreshable {
            await viewModel.loadInstructors()
        }
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
