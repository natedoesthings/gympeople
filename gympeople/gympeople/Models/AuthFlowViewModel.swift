//
//  AuthFlowViewMode;.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/11/25.
//

import Foundation
import Supabase
import AuthenticationServices
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var isLoading: Bool = false
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published var userEmail: String = ""
    @Published var loginError: LoginError?
    @Published var needsOnboarding: Bool = false

    private let client = SupabaseManager.shared.client
    private var authStateTask: Task<Void, Never>?

    init() {
        // Start listening for sign-in/sign-out changes
        authStateTask = Task { [weak self] in
            guard let self else { return }

            for await change in client.auth.authStateChanges {
                switch change.event {
                case .signedIn, .tokenRefreshed:
                    await self.updateUserFromSession()
                case .signedOut, .userDeleted:
                    resetState()
                default:
                    break
                }
            }
        }

        // On startup, check if there's already a valid session
        Task { await updateUserFromSession() }
    }

    deinit {
        authStateTask?.cancel()
    }

    func signInWithGoogle() async {
        do {
            let redirectURL = URL(string: "\(Bundle.main.bundleIdentifier!)://login-callback/")!
            try await client.auth.signInWithOAuth(
                provider: .google,
                redirectTo: redirectURL
            )
            
        } catch {
            LOG.error("Google sign-in failed: \(error)")
        }
    }
    
    // MARK: - Email + Password Sign Up
    func signUpWithEmail(email: String, password: String, firstName: String? = nil, lastName: String? = nil) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let result = try await client.auth.signUp(
                email: email,
                password: password,
                data: firstName != nil && lastName != nil ? ["name": .string(firstName! + " " + lastName!)] : nil
            )
            LOG.info("Signed up: \(result.user.email ?? "")")
        } catch {
            let loginErr = LoginError.from(error)
            LOG.error("Sign-in failed: \(loginErr.message)")
            self.loginError = loginErr
        }
    }

    // MARK: - Email + Password Sign In
    func signInWithEmail(email: String, password: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await client.auth.signIn(email: email, password: password)
        } catch {
            let loginErr = LoginError.from(error)
            LOG.error("Sign-in failed: \(loginErr.message)")
            self.loginError = loginErr
            resetState()
        }
    }

    func handleAuthCallback(url: URL) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await client.auth.session(from: url)
        } catch {
            LOG.error("Auth callback failed: \(error)")
        }
    }

    private func updateUserFromSession() async {
        LOG.debug("Updating User Session")
        isLoading = true
        defer { isLoading = false }
        
        do {
            LOG.debug("Searching for Session")
            
            let session = try await client.auth.session
            let user = session.user
            
            LOG.debug("Session Found for User: \(user.id)")

            // Update basic user info
            if let nameField = user.userMetadata["name"],
               case .string(let name) = nameField {
                let fullname = name.components(separatedBy: " ")
                self.firstName = fullname[0]
                self.lastName = fullname[1]
            } else {
                self.firstName = user.email ?? "Unknown"
            }
            
            self.userEmail = user.email ?? ""
            self.isSignedIn = true

            // Check if the user has completed onboarding
            do {
                LOG.debug("Searching for onboarding record for \(user.id)")
                let _ = try await client
                    .from("user_profiles")
                    .select()
                    .eq("id", value: user.id)
                    .single()
                    .execute()

                self.needsOnboarding = false
                LOG.info("User already onboarded")

            } catch {
                LOG.error("Error checking onboarding status: \(error)")
                self.needsOnboarding = true
            }

        } catch {
            LOG.error("Error getting session: \(error)")
            resetState()
        }
    }
    
    private func resetState() {
        isSignedIn = false
        firstName = ""
        userEmail = ""
        needsOnboarding = false
        isLoading = false
    }

    func signOut() async {
        do {
            LOG.debug("Signing Out \(userEmail)")
            try await client.auth.signOut()
            resetState()
            LOG.debug("Signed Out \(userEmail)")
        } catch {
            LOG.error("Sign-out error: \(error)")
        }
    }
    
    
}
