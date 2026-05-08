import SwiftUI

struct InstructorDashboardView: View {
    @ObservedObject var viewModel: InstructorProfileViewModel
    
    private let gridColumns: [GridItem] = [
        GridItem(.adaptive(minimum: 260, maximum: 320), spacing: 16, alignment: .center)
    ]

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Today's Rentals")
                        .font(.headline)
                        .foregroundStyle(Color(.secondaryLabel))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 4)

                    Group {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 80)
                        } else if let error = viewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding()
                                .frame(maxWidth: .infinity)
                        } else if viewModel.todaysRentals.isEmpty {
                            VStack(spacing: 8) {
                                Image(systemName: "calendar.badge.checkmark")
                                    .font(.system(size: 40))
                                    .foregroundStyle(Color(.tertiaryLabel))
                                Text("No rentals for today")
                                    .foregroundStyle(Color(.secondaryLabel))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 48)
                        } else {
                            LazyVGrid(columns: gridColumns, alignment: .center, spacing: 16) {
                                ForEach(viewModel.todaysRentals) { rental in
                                    InstructorRentalCard(
                                        rental: rental,
                                        onEdit: { viewModel.openEdit(for: rental) },
                                        onEnd: {
                                            Task { await viewModel.endRental(rental) }
                                        },
                                        mediaRefreshToken: viewModel.mediaRefreshToken
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            if viewModel.isEditPopupPresented, let rental = viewModel.selectedRental {
                Color.black.opacity(0.35)
                    .ignoresSafeArea()
                    .onTapGesture { viewModel.closeEdit() }

                EditRentalEndTimePopup(
                    rental: rental,
                    onConfirm: { newEndTime in
                        Task { await viewModel.updateRentalEndTime(rental, endTime: newEndTime) }
                    },
                    onClose: { viewModel.closeEdit() }
                )
                .transition(.scale)
                .zIndex(10)
            }
        }
        .animation(.spring(), value: viewModel.isEditPopupPresented)
        .scrollIndicators(.visible)
        .background(Color(.systemGroupedBackground))
        .refreshable {
            await viewModel.loadProfile()
        }
        .alert("Błąd", isPresented: Binding(get: { viewModel.actionErrorMessage != nil }, set: { if !$0 { viewModel.actionErrorMessage = nil } })) {
            Button("OK") { viewModel.actionErrorMessage = nil }
        } message: {
            Text(viewModel.actionErrorMessage ?? "")
        }
    }
}

#Preview {
    InstructorDashboardView(viewModel: InstructorProfileViewModel())
}
