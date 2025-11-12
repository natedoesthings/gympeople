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
    @Published var userName: String = ""

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
                    self.isSignedIn = false
                    self.userName = ""
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
            print("Google sign-in failed: \(error)")
        }
    }
    
    // MARK: - Email + Password Sign Up
    func signUpWithEmail(email: String, password: String, name: String? = nil) async {
        do {
            let result = try await client.auth.signUp(
                email: email,
                password: password,
                data: name != nil ? ["name": .string(name!)] : nil
            )
            print("Signed up: \(result.user.email ?? "")")
            await updateUserFromSession()
        } catch {
            print("Sign-up failed: \(error)")
        }
    }

    // MARK: - Email + Password Sign In
    func signInWithEmail(email: String, password: String) async {
        do {
            try await client.auth.signIn(email: email, password: password)
            await updateUserFromSession()
        } catch {
            print("Sign-in failed: \(error)")
        }
    }

    func handleAuthCallback(url: URL) async {
        do {
            try await client.auth.session(from: url)
        } catch {
            print("Auth callback failed: \(error)")
        }
    }

    private func updateUserFromSession() async {
        do {
            let session = try await client.auth.session
            let user = session.user
            
            if let nameField = user.userMetadata["name"],
               case .string(let name) = nameField {
                self.userName = name
            } else {
                self.userName = user.email ?? "Unknown"
            }
            
            self.isSignedIn = true

        } catch {
            print("Error getting session: \(error)")
            self.isSignedIn = false
            self.userName = ""
        }
    }

    func signOut() async {
        do {
            try await client.auth.signOut()
            isSignedIn = false
            userName = ""
        } catch {
            print("Sign-out error: \(error)")
        }
    }
}
