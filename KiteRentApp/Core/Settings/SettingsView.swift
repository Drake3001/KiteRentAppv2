//
//  SettingsView.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 21/11/2025.
//

import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    
    func signOut() throws{
        try AuthenticationManager.shared.signOut()
    }
}

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            Button("Log out") {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        //print() <- error
                    }
                }
            }
        }
        .navigationBarTitle("Settings")
    }
}

//#Preview {
//    SettingsView(showSignInView: .constant(false))
//}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SettingsView(showSignInView: .constant(false))
        }
    }
}
