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
    
    func signOut() throws{
        try AuthenticationManager.shared.signOut()
    }
}
