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
    @State private var hasCheckedInitialSession = false
    
    var body: some View {
        VStack(spacing: 24) {
            if !hasCheckedInitialSession {
                // Show loading view during initial session check
                LoadingView()
            } else if !authVM.isSignedIn {
                LandingPageView()
            } else {
                if !authVM.needsOnboarding {
                    GymPeopleView()
                } else {
                    // Possible that user still needs to onboard
                    EmptyView()
                }
            }
        }
        .onChange(of: authVM.isLoading) { _, isLoading in
            // Once we've finished the initial loading check, mark it as done
            if !isLoading && !hasCheckedInitialSession {
                hasCheckedInitialSession = true
            }
        }
        .onChange(of: authVM.needsOnboarding) { _, needsOnboarding in
            LOG.debug("Needs Onboarding: \(needsOnboarding)")
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
        .animation(.easeInOut(duration: 0.3), value: authVM.isLoading)
        .animation(.easeInOut(duration: 0.3), value: authVM.isSignedIn)
        .animation(.easeInOut(duration: 0.3), value: authVM.needsOnboarding)
    }
}
