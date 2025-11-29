import Foundation
import Combine

@MainActor
final class KitesurfingListViewModel: ObservableObject {
    @Published var kites: [DBKite] = []
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    var filteredKites: [DBKite] {
        guard !searchText.isEmpty else { return kites }
        return kites.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    func loadKites() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await KiteManager.shared.getAllKites()
            self.kites = fetched
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
