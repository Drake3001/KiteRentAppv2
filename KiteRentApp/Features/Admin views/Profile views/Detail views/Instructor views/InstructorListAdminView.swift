//
//  InstructorListAdminView.swift
//  KiteRentApp
//
//  Created by Filip on 11/12/2025.
//

import SwiftUI

struct InstructorListAdminView: View {
    @StateObject private var viewModel = InstructorListAdminViewModel()
    @StateObject private var deleteViewModel = AdminInstructorDeleteViewModel()

    @State private var selectedInstructorForEditing: DBInstructor? = nil
    @State private var isShowingCreateAccount = false

    @State private var instructorToDelete: DBInstructor? = nil
    @State private var showDeleteConfirmation = false

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
                            InstructorAdminView(
                                instructor: instructor,
                                onEditTapped: { inst in
                                    selectedInstructorForEditing = inst
                                },
                                onDeleteTapped: { inst in
                                    instructorToDelete = inst
                                    showDeleteConfirmation = true
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
        .confirmationDialog(
            "Delete instructor?",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete instructor", role: .destructive) {
                if let inst = instructorToDelete {
                    Task { await performDeletion(inst) }
                }
            }
            Button("Cancel", role: .cancel) {
                instructorToDelete = nil
            }
        } message: {
            if let inst = instructorToDelete {
                Text("This permanently removes \(inst.name) \(inst.surname), their user profile, and their login account. This cannot be undone.")
            }
        }
        .alert("Error", isPresented: $deleteViewModel.showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(deleteViewModel.errorMessage)
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

    private func performDeletion(_ instructor: DBInstructor) async {
        let ok = await deleteViewModel.deleteInstructorCompletely(instructorId: instructor.instructorId)
        instructorToDelete = nil
        if ok {
            await viewModel.loadInstructors()
        }
    }
}

#Preview {
    ZStack {
        AdminGlassBackground()
        InstructorListAdminView()
    }
}
