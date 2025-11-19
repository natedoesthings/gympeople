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
//    @State private var firstName: String = "Nathanael"
//    @State private var lastName: String = "Tesfaye"
//    @State private var userName: String = "Nate"
//    @State private var gyms: [String] = ["YMCA"]
    @State private var errorMessage: String?
    
    @State private var avatarImage: UIImage?
    @State private var photosPickerItem: PhotosPickerItem?
    
    @State private var pfpIsLoading: Bool = false
    @State private var hasLoadedProfile: Bool = false
    
    @State private var showProfileEditingPage: Bool = false
    
    let manager = SupabaseManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            if let userProfile = userProfile {
                // Profile picture displayer and selector
                NavigationStack {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        PhotosPicker(selection: $photosPickerItem, matching: .images) {
                            if !pfpIsLoading {
                                Image(uiImage: avatarImage ?? UIImage(systemName: "person.circle.fill")!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 75, height: 75)
                                    .clipShape(.circle)
                            } else {
                                Image(uiImage: UIImage(systemName: "person.circle.fill")!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 75, height: 75)
                                    .clipShape(.circle)
                            }
                        }
                        
                        HStack {
                            Text(userProfile.first_name)
                            Text(userProfile.last_name)
                        }
                        .padding(.top, 5)
                        .font(.title3)
                        .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("@\(userProfile.user_name)")
                            if !userProfile.biography.isEmpty {
                                Text("\(userProfile.biography)")
                            }
                        }
                        .font(.caption)
                        .foregroundStyle(Color.standardSecondary)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            ScrollView(.horizontal) {
                                HStack {
                                    if let gyms = userProfile.gym_memberships {
                                        ForEach(gyms, id: \.self) { gym in
                                            gymTagButton(gymTagType: .gym(gym: gym))
                                        }
                                        gymTagButton(gymTagType: .plus)
                                    }
                                    else {
                                        gymTagButton(gymTagType: .none)
                                    }
                                }
                                .padding(1)
                            }
                        }
                        .padding(.vertical, 15)
                        
                        

                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            HStack {
                                Button {
                                    showProfileEditingPage = true
                                } label: {
                                    Image(systemName: "pencil")
                                }
                                
                                NavigationLink {
                                    ProfileSettingsPageView()
                                } label: {
                                    Image(systemName: "slider.horizontal.3")
                                }
                            }
                        }
                    }
                }
                .sheet(isPresented: $showProfileEditingPage) {
                    ProfileEditingPageView(userProfile: $userProfile, hasLoadedProfile: $hasLoadedProfile)
                }
                
            } else if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            } else {
                ProgressView("Loading Profile...")
            }
        }
        .onAppear {
            if !hasLoadedProfile {
                hasLoadedProfile = true
                Task { await loadProfile() }
            }
        }
        .onChange(of: photosPickerItem) { _, _ in
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
            LOG.debug("Fetching user profile")
            userProfile = try await manager.fetchUserProfile()
            LOG.debug("Fetched user profile")
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
            errorMessage = error.localizedDescription.debugDescription
        }
    }
    
    @ViewBuilder
    private func gymTagButton(gymTagType: GymTagType) -> some View {
        Button {
            showProfileEditingPage = true
        } label: {
            HStack {
                switch gymTagType {
                case .none:
                    Text("Add gyms")
                    Image(systemName: "plus")
                case .gym(let gym):
                    Text("\(gym)")
                case .plus:
                    Image(systemName: "plus")
                }
                
            }
            .padding(5)
            .font(.caption)
            .foregroundColor(Color.brandOrange)
            .cornerRadius(20)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.brandOrange, lineWidth: 2)
            )
        }
    }
}

//#Preview {
//    ProfileView()
//}





