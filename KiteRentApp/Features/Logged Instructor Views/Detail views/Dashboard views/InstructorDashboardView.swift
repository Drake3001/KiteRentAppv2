import SwiftUI

struct InstructorDashboardView: View {
    @ObservedObject var viewModel: InstructorProfileViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text("Today's Schedule")
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
                            Text("No lessons scheduled for today")
                                .foregroundStyle(Color(.secondaryLabel))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 48)
                    } else {
                        VStack(spacing: 16) {
                            ForEach(viewModel.todaysRentals) { rental in
                                InstructorRentalCard(rental: rental)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .scrollIndicators(.visible)
        .background(Color(.systemGroupedBackground))
        .refreshable {
            await viewModel.loadProfile()
        }
    }
}

#Preview {
    InstructorDashboardView(viewModel: InstructorProfileViewModel())
}
