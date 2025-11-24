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
    @State private var posts: [Post]?

    @State private var errorMessage: String?
    
    @State private var photosPickerItem: PhotosPickerItem?
    
    @State private var hasLoadedProfile: Bool = false
    
    @State private var showProfileEditingPage: Bool = false
    @State private var profileTab: ProfileTabs = .posts
    
    let manager = SupabaseManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            if let userProfile = userProfile {
                // Profile picture displayer and selector
                NavigationStack {
                    VStack(alignment: .leading, spacing: 4) {
                        // Profile Picture
                        PhotosPicker(selection: $photosPickerItem, matching: .images) {
                            AvatarView(url: userProfile.pfp_url)
                                .frame(width: 75, height: 75)
                        }
                        
                        // Name, user, bio
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
                        
                        // Gym Tags
                        VStack(alignment: .leading, spacing: 15) {
                            ScrollView(.horizontal) {
                                HStack {
                                    if let gyms = userProfile.gym_memberships {
                                        ForEach(gyms, id: \.self) { gym in
                                            gymTagButton(gymTagType: .gym(gym: gym))
                                        }
                                    } else {
                                        gymTagButton(gymTagType: .none)
                                    }
                                    
                                    gymTagButton(gymTagType: .plus)
                                }
                                .padding(1)
                            }
                        }
                        .padding(.vertical, 15)
                        
                        Picker("", selection: $profileTab) {
                            ForEach(ProfileTabs.allCases) { tab in
                                Text(tab.rawValue).tag(tab)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        switch profileTab {
                        case .posts:
                            ScrollView {
                                LazyVStack {
                                    if let posts = posts {
                                        ForEach(posts, id: \.self) { post in
                                            PostCard(post: post, displayName: userProfile.first_name, username: userProfile.user_name, avatarURL: userProfile.pfp_url)
                                            
                                            Divider()
                                        }
                                    }
                                }
                            }
                        case .mentions:
                            Text("Your mentions")
                        }
                        
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
                                    ProfileSettingsPageView(userProfile: userProfile)
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
                Task {
                    await loadProfile()
                }
                hasLoadedProfile = true
            }
        }
        .onChange(of: photosPickerItem) { _, _ in
            Task {
                if let photosPickerItem {
                    if let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: data) {
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
            // Fetch posts
            LOG.debug("Fetching users posts")
            posts = try await manager.fetchMyPosts()
            LOG.debug("Fetched users posts")
            
            // Fetch profile
            LOG.debug("Fetching user profile")
            userProfile = try await manager.fetchUserProfile()
            LOG.debug("Fetched user profile")
            
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

// #Preview {
//     
//     let userProfile = UserProfile.init(id: UUID(), first_name: "Nate", last_name: "dasd", user_name: "", biography: "ds", email: "dsd", date_of_birth: Date(), phone_number: "", created_at: Date())
//     
//     ProfileView(userProfile: .constant(userProfile))
// }
