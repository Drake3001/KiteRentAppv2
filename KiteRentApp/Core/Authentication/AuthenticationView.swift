    //
//  AuthenticationView.swift
//  KiteRentApp
//
//  Created by Ranger5301 on 21/11/2025.
//

import SwiftUI

struct AuthenticationView: View {
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        //View for logging as admin
        VStack {
            NavigationLink {
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sing In Wih Email")
            }
            
            Spacer()
        }
    }
}

//#Preview {
//    AuthenticationView()
//}

struct AuthenticationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AuthenticationView(showSignInView: .constant(false))
        }
    }
}
