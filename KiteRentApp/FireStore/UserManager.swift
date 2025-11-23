//
//  UserManager.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 22/11/2025.
//

import Foundation
import FirebaseFirestore

final class UserManager {
    
    static let shared = UserManager()
    private init() { } 
    
    private let userCollection = Firestore.firestore().collection("users")
    
    private func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }

//    private let encoder: Firestore.Encoder = {
//        let encoder = Firestore.Encoder()
//        encoder.keyEncodingStrategy = .convertToSnakeCase
//        return encoder
//    }()

    
    
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false)
    }
    
//    func createNewUser(auth: AuthDataResultModel) async throws {
//        var userData: [String:Any] = [
//            "user_id" : auth.uid,
//            "date_created": Timestamp(),
////            "email" : auth.email ?? ""
//        ]
//        if let email =  auth.email {
//            userData["email"] = email
//        }
//        try await userDocument(userId: auth.uid).setData(userData, merge: false)
////        try await Firestore.firestore().collection("users").document(auth.uid).setData(userData, merge: false)
//    }
    
    func getUser(userId: String) async throws -> DBUser {
        try await userDocument(userId: userId).getDocument(as: DBUser.self)
    }
    
//    func getUser(userId: String) async throws -> DBUser {
////        let snapshot = try await Firestore.firestore().collection("users").document(userId).getDocument()
//        let snapshot = try await userDocument(userId: userId).getDocument()
//        
//        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
//            throw URLError(.badServerResponse)
//        }
//        
//        let email = data["email"] as? String
//        let timestamp = data["date_created"] as? Timestamp
//        let dateCreated = timestamp?.dateValue()
//
//        
//        return DBUser(userId: userId, email: email, dateCreated: dateCreated)
//    }
}
