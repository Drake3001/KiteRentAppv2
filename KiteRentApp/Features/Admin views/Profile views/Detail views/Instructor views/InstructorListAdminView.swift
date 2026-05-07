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
    @State private var isShowingCreateAccount = false

    @FocusState private var isSearchFocused: Bool

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                SearchBarView(text: $viewModel.searchText)
                    .focused($isSearchFocused)

                FilterRowView(
                    numberOfElements: viewModel.filteredAndOrderedInstructors.count,
                    onSortTapped: { viewModel.isSortAscending.toggle() },
                    isAscending: viewModel.isSortAscending
                )

                newInstructorButton

                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(viewModel.filteredAndOrderedInstructors) { instructor in
                            InstructorAdminView(instructor: instructor) { instructor in
                                selectedInstructorForEditing = instructor
                            }
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
        .sheet(isPresented: $isShowingCreateAccount) {
            Task { await viewModel.loadInstructors() }
        } content: {
            CreateInstructorAccountView()
        }
    }

    private var newInstructorButton: some View {
        Button {
            isShowingCreateAccount = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "person.badge.plus")
                    .font(.body.weight(.semibold))
                Text("New Instructor Account")
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
}

#Preview {
    ZStack {
        AdminGlassBackground()
        InstructorListAdminView()
    }
}
