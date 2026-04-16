//
//  SettingsViewModel.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 22/11/2025.
//

import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    private let authManager: AuthenticationManagerProtocol

    init(authManager: AuthenticationManagerProtocol? = nil) {
        self.authManager = authManager ?? AuthenticationManager.shared
    }
    
    func signOut() throws{
        try authManager.signOut()
    }
}
