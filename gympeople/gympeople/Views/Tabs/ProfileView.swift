//
//  ProfileView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var userProfile: UserProfile?
    @State private var errorMessage: String?
    
    let manager = SupabaseManager.shared
    
    var body: some View {
        VStack {
            if let userProfile = userProfile {
                VStack(spacing: 8) {
                    Text("Welcome, \(userProfile.full_name)")
                        .font(.title2)
                        .bold()
                    Text("Email: \(userProfile.email)")
                }
                .padding()
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                ProgressView("Loading profile...")
            }
        }
        .task {
            do {
                userProfile = try await manager.fetchUserProfile()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
