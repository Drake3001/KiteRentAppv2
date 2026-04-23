//
//  KiteRentAppApp.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 21/11/2025.
//

import SwiftUI
import SwiftData
import Firebase

@main
struct KiteRentAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
         
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                StartScreenView()
            }
        }
        .modelContainer(MediaPersistence.modelContainer)
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

