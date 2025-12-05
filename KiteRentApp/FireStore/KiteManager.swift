import Foundation
import FirebaseFirestore

final class KiteManager {
    static let shared = KiteManager()
    private init() { }

    private let kiteCollection = Firestore.firestore().collection("kites")

    private func kiteDocument(kiteId: String) -> DocumentReference {
        kiteCollection.document(kiteId)
    }

    func createNewKite(kite: DBKite) async throws {
        try kiteDocument(kiteId: kite.id).setData(from: kite, merge: false)
    }

    func getAllKites() async throws -> [DBKite] {
        let snapshot = try await kiteCollection.getDocuments()
        return try snapshot.documents.map { doc in
            var kite = try doc.data(as: DBKite.self)
            kite.id = doc.documentID
            return kite
        }
    }

    func getKite(kiteId: String) async throws -> DBKite {
        let document = try await kiteDocument(kiteId: kiteId).getDocument()
        var kite = try document.data(as: DBKite.self)
        kite.id = document.documentID
        return kite
    }

    func updateKiteState(kiteId: String, state: KiteState) async throws {
        try await kiteDocument(kiteId: kiteId).updateData(["state": state.rawValue])
    }

    func listenToKites(completion: @escaping (Result<[DBKite], Error>) -> Void) -> ListenerRegistration {
        kiteCollection.addSnapshotListener { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapshot = snapshot else {
                completion(.failure(NSError(domain: "KiteManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No snapshot"])))
                return
            }
            do {
                let kites = try snapshot.documents.map { doc -> DBKite in
                    var kite = try doc.data(as: DBKite.self)
                    kite.id = doc.documentID
                    return kite
                }
                completion(.success(kites))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
