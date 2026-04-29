import SwiftUI

struct InstructorProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    let onOpenSettings: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            // Instructor sees only rentals (no kite/instructor management)
            RentalListAdminView()  // or a read-only version
        }
        .background(Color(.systemBackground))
        .task { try? await viewModel.loadCurrentUser() }
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
