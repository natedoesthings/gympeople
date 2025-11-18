//
//  ProfileView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @State private var userProfile: UserProfile?
    @State private var userName = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    
    @State private var avatarImage: UIImage?
    @State private var photosPickerItem: PhotosPickerItem?
    
    @State private var pfpIsLoading: Bool = false
    @State private var hasLoadedProfile: Bool = false
    
    let manager = SupabaseManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            if let _ = userProfile {
                // Profile picture displayer and selector
                PhotosPicker(selection: $photosPickerItem, matching: .images) {
                    if !pfpIsLoading {
                        Image(uiImage: avatarImage ?? UIImage(systemName: "person.circle.fill")!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(.circle)
                    } else {
                        ProgressView()
                    }
                }
                
                TextField("User Name", text: $userName)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                Button("Save Changes") {
                    Task {
                        await updateUserName()
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
        .onAppear {
            if !hasLoadedProfile {
                hasLoadedProfile = true
                Task { await loadProfile() }
            }
        }
        .onChange(of: photosPickerItem) { _,_ in
            Task {
                if let photosPickerItem {
                    if let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: data) {
                            avatarImage = image
                            do {
                                try await manager.uploadProfilePicture(image)
                            } catch {
                                LOG.error("Could not upload profile picture: \(error)")
                            }
                            
                        }
                    }
                }
                
                photosPickerItem = nil
            }
            
        }
    }
    
    private func loadProfile() async {
        do {
            userProfile = try await manager.fetchUserProfile()
            userName = userProfile?.user_name ?? ""
            
            // Update image from url
            pfpIsLoading = true
            
            if let pfpURLString = userProfile?.pfp_url, let url = URL(string: pfpURLString) {
                if let (data, _) = try? await URLSession.shared.data(from: url),
                   let image = UIImage(data: data) {
                    avatarImage = image
                }
            }
            
            pfpIsLoading = false
            
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func updateUserName() async {
        do {
            try await manager.updateUserProfile(fields: ["user_name": AnyEncodable(userName)])
            successMessage = "Profile updated successfully!"
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
