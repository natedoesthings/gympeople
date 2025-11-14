//
//  LoginView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/11/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var isCreatingAccount = false
    
    var body: some View {
        VStack(spacing: 24) {
            if !authVM.isSignedIn {
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
            } else if authVM.needsOnboarding {
                OnboardingView(firstName: $authVM.firstName, lastName: $authVM.lastName, email: $authVM.userEmail)
            } else { // signed in and passed onboarding
                HomeView()
            }
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
    }
}


