//
//  LoginView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/11/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showOnboarding = false
    
    var body: some View {
        VStack(spacing: 24) {
            if authVM.isLoading {
                VStack {
                    ProgressView("Signing in...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .padding()
                    Text("Please wait a moment")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .transition(.opacity)
            } else if !authVM.isSignedIn {
                SignInView()
            } else {
                
                if !authVM.needsOnboarding {
                    HomeView()
                } else {
                    // Possible that user still needs to onboard
                    EmptyView()
                }
            }
        }
        .onChange(of: authVM.needsOnboarding) { _, needsOnboarding in
            // When user signs in and needs onboarding, present the flow
            if needsOnboarding && authVM.isSignedIn {
                showOnboarding = true
            }
        }
        .fullScreenCover(isPresented: $showOnboarding, onDismiss: {
            // If onboarding was dismissed but still marked as needed,
            // user backed out. Sign them out.
            if authVM.needsOnboarding {
                Task { await authVM.signOut() }
            }
        }) {
            OnboardingView(
                firstName: $authVM.firstName,
                lastName: $authVM.lastName,
                email: $authVM.userEmail,
                onCancel: {
                    showOnboarding = false
                    Task { await authVM.signOut() }
                },
                onFinished: {
                    authVM.needsOnboarding = false
                    showOnboarding = false
                }
            )
        }
        .alert(item: $authVM.loginError) { loginError in
            Alert(
                title: Text("Login Error"),
                message: Text(loginError.message),
                dismissButton: .default(Text("OK")) {
                    authVM.loginError = nil
                }
            )
        }
        .animation(.easeInOut, value: authVM.isLoading)
    }
}


struct SignInView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var isCreatingAccount = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text(isCreatingAccount ? "Sign Up" : "Sign In")
                .font(.title)
                .fontWeight(.heavy)
            
            Text("Find your GymPeople today.")
                .font(.subheadline)
            
            HStack {
                Button {
                    Task { await authVM.signInWithGoogle() }
                } label: {
                    Label {
                        Text("Google")
                    } icon: {
                        Image("google_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                    }
                    .font(.system(size: 16))
                    .padding()
                    .foregroundColor(.black)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                    )
                    .cornerRadius(10)
                }
                
                Button {
                    Task { await authVM.signInWithGoogle() }
                } label: {
                    Label("Apple", systemImage: "apple.logo")
                        .font(.system(size: 16))
                        .padding()
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal, 5)

            
            HStack {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.4))
                
                Text("or")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray.opacity(0.4))
            }
            .padding(.vertical)
            .padding(.horizontal, 20)
            
            EmailAuthView(isCreatingAccount: $isCreatingAccount)
            
        }
        .padding(.horizontal, 10)
    }
}


