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
    @State private var showEditProfile = false
    @State private var showMediaPlayback = false

    let onLogout: () -> Void
    var onProfileUpdated: (() -> Void)? = nil
    /// When `true`, shows instructor self-service profile editing (opened from instructor flow).
    var showInstructorEditProfile: Bool = false

    var body: some View {
        List {
            Section {
                if showInstructorEditProfile {
                    Button("Edit Profile") {
                        showEditProfile = true
                    }
                }
                Button("Change Password") {
                    showChangePassword = true
                }
                Button("video & audio") {
                    showMediaPlayback = true
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
        .sheet(isPresented: $showMediaPlayback) {
            SettingsMediaPlaybackView()
        }
    }
}
