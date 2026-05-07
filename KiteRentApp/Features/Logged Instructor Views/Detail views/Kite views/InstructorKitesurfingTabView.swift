import SwiftUI

struct InstructorKitesurfingTabView: View {
    @ObservedObject var viewModel: KitesurfingListViewModel

    var body: some View {
        KitesurfingListContentView(
            viewModel: viewModel,
            onLoginTapped: nil,
            showsHeader: false,
            presentsScannerSheet: false,
            presentsErrorAlert: false,
            showsReservationOverlay: false
        )
    }
}
