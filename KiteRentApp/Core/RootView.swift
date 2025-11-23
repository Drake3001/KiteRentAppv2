//
//  RootView.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 21/11/2025.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSingInView: Bool = false
    
    var body: some View {
        ZStack {
//            if !showSingInView {
                NavigationStack {
                    ProfileView(showSignInView: $showSingInView)
//                    SettingsView(showSignInView: $showSingInView)
//                }
            }
        }
        .onAppear {
                let authuser = try? AuthenticationManager.shared.getAuthenticatedUser()
                self.showSingInView = authuser == nil
            }
            .fullScreenCover(isPresented: $showSingInView) {
                NavigationStack {
                    AuthenticationView(showSignInView: $showSingInView)
                }
            }
        }
    }


//#Preview {
//    RootView()
//}
struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
