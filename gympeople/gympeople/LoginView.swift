//
//  LoginView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/11/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 24) {
            if viewModel.isSignedIn {
                VStack(spacing: 12) {
                    Text("Welcome, \(viewModel.userName)")
                        .font(.title)
                        .fontWeight(.bold)
                    Button("Sign Out") {
                        Task { await viewModel.signOut() }
                    }
                    .foregroundColor(.red)
                }
            } else {
                VStack(spacing: 20) {
                    Button {
                        Task { await viewModel.signInWithGoogle() }
                    } label: {
                        Label("Continue with Google", systemImage: "globe")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue.opacity(0.9))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.horizontal, 40)
            }
        }
        .onOpenURL { url in
            Task {
                await viewModel.handleAuthCallback(url: url)
            }
        }
    }
}

