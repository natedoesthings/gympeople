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

    init() {
        Task {
            await checkSession()
        }
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

    func handleAuthCallback(url: URL) async {
        do {
            try await client.auth.session(from: url)
            await checkSession()
        } catch {
            print("Auth callback failed: \(error)")
        }
    }

    func checkSession() async {
        do {
            let session = try await client.auth.session
            let user = session.user

            // Extract "name" from userMetadata ([String: AnyJSON])
            var nameFromMetadata: String?
            if let anyJSON = user.userMetadata["name"] {
                switch anyJSON {
                case .string(let s):
                    nameFromMetadata = s
                default:
                    // Fallback: attempt to stringify other JSON types
                    nameFromMetadata = anyJSON.description
                }
            }

            self.userName = nameFromMetadata ?? user.email ?? "Unknown"
            self.isSignedIn = true
        } catch {
            print("No active session: \(error)")
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
