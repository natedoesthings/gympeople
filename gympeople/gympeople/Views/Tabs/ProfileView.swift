//
//  ProfileView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI

struct ProfileView: View {
    @State private var userProfile: UserProfile?
    @State private var userName = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    let manager = SupabaseManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            if let profile = userProfile {
                TextField("User Name", text: $userName)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                Button("Save Changes") {
                    Task {
                        await updateProfile()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(userName.isEmpty)
                
                if let success = successMessage {
                    Text(success).foregroundColor(.green)
                }
            } else if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else {
                ProgressView("Loading Profile...")
            }
        }
        .padding()
        .task {
            await loadProfile()
        }
    }
    
    private func loadProfile() async {
        do {
            userProfile = try await manager.fetchUserProfile()
            userName = userProfile?.user_name ?? ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func updateProfile() async {
        do {
            try await manager.updateUserName(newUserName: userName)
            successMessage = "Profile updated successfully!"
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
