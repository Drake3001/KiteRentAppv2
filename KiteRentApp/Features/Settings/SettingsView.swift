//
//  SettingsView.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 21/11/2025.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showChangePassword = false
    
    let onLogout: () -> Void
    var body: some View {
        List {
            Section {
                Button("Change Password") {
                    showChangePassword = true
                }
            }
            
            Section {
                Button("Log out") {
                    Task {
                        do {
                            try viewModel.signOut()
                            onLogout()
                        } catch {
                            print("error")
                        }
                    }
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showChangePassword) {
            ChangePasswordView()
        }
    }
}


