import SwiftUI

struct InstructorProfileView: View {
    @StateObject private var viewModel = InstructorProfileViewModel()
    @Environment(\.colorScheme) private var colorScheme
    let onOpenSettings: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if let instructor = viewModel.instructor {
                Text("\(instructor.name) \(instructor.surname)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 12)

                Text("Today's Schedule")
                    .font(.headline)
                    .foregroundStyle(Color(.secondaryLabel))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, 4)
            }

            if viewModel.isLoading {
                Spacer()
                ProgressView()
                Spacer()
            } else if let error = viewModel.errorMessage {
                Spacer()
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
                Spacer()
            } else if viewModel.todaysRentals.isEmpty {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 40))
                        .foregroundStyle(Color(.tertiaryLabel))
                    Text("No lessons scheduled for today")
                        .foregroundStyle(Color(.secondaryLabel))
                }
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.todaysRentals) { rental in
                            InstructorRentalCard(rental: rental)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                }
                .background(Color(.systemGroupedBackground))
            }
        }
        .background(Color(.systemBackground))
        .task { await viewModel.loadProfile() }
        .refreshable { await viewModel.loadProfile() }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { } label: {
                    Image(systemName: "wind").font(.headline)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button { onOpenSettings() } label: {
                    Image(systemName: "gear").font(.headline)
                }
            }
        }
    }
}

private struct InstructorRentalCard: View {
    let rental: InstructorRental
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(rental.kiteName)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(1)

            HStack {
                HStack {
                    Image(systemName: "clock")
                    Text("\(rental.startTime.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits))) - \(rental.endTime.formatted(.dateTime.hour(.twoDigits(amPM: .omitted)).minute(.twoDigits)))")
                }

                Spacer()

                let diff = Calendar.current.dateComponents([.hour, .minute], from: rental.startTime, to: rental.endTime)
                Text("\(diff.hour ?? 0)h \(diff.minute ?? 0)m")
            }
            .font(.subheadline)
            .foregroundStyle(Color(.secondaryLabel))
        }
        .padding()
        .background(Color(.tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.primary.opacity(colorScheme == .dark ? 0.15 : 0.05), radius: 2, y: 4)
        .frame(maxWidth: .infinity)
    }
}
