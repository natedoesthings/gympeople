//
//  LoginView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/11/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            if authVM.isSignedIn {
                VStack(spacing: 12) {
                    Text("Welcome, \(authVM.userName)")
                        .font(.title)
                        .fontWeight(.bold)
                    Button("Sign Out") {
                        Task { await authVM.signOut() }
                    }
                    .foregroundColor(.red)
                }
            } else {
                
                VStack(spacing: 20) {
                    Button {
                        Task { await authVM.signInWithGoogle() }
                    } label: {
                        Label("Continue with Google", systemImage: "globe")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    Divider().padding(.vertical)

                    EmailAuthView()
                    

                }
                .padding(.horizontal, 40)
                
                
            }
        }
        .onOpenURL { url in
            Task {
                await authVM.handleAuthCallback(url: url)
            }
        }
    }
}

