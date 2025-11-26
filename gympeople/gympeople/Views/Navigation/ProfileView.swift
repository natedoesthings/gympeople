//
//  ProfileView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @State private var userProfile: UserProfile = .placeholder()
    @State private var posts: [Post]?

    @State private var errorMessage: String?
    
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var hasLoadedProfile: Bool = false
    
    @State private var showProfileEditingPage: Bool = false
    @State private var profileTab: ProfileTab = .posts
    @State private var outerDisabled = false
    
    let manager = SupabaseManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            if hasLoadedProfile {
                // Profile picture displayer and selector
                NavigationStack {
                    HiddenScrollView {
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
                                if let bio = userProfile.biography {
                                    Text("\(bio)")
                                }
                            }
                            .font(.caption)
                            .foregroundStyle(Color.standardSecondary)
                            
                            // Gym Tags
                            VStack(alignment: .leading, spacing: 15) {
                                HiddenScrollView(.horizontal) {
                                    HStack {
                                        if !userProfile.gym_memberships.isEmpty {
                                            ForEach(userProfile.gym_memberships, id: \.self) { gym in
                                                Button {
                                                    showProfileEditingPage = true
                                                } label: {
                                                    GymTagButton(gymTagType: .gym(gym: gym))
                                                }
                                            }
                                            
                                            NavigationLink {
                                                GymEditingView(gym_memberships: $userProfile.gym_memberships)
                                            } label: {
                                                GymTagButton(gymTagType: .plus)
                                            }
                                        } else {
                                            NavigationLink {
                                                GymEditingView(gym_memberships: $userProfile.gym_memberships)
                                            } label: {
                                                GymTagButton(gymTagType: .none)
                                            }
                                            
                                        }
                                    }
                                    .padding(1)
                                }
                            }
                            .padding(.vertical, 15)
                            
                            Picker("", selection: $profileTab) {
                                ForEach(ProfileTab.allCases) { tab in
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
                                .gesture(
                                    DragGesture()
                                        .onChanged { _ in outerDisabled = true }
                                        .onEnded { _ in outerDisabled = false }
                                )
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
                    .refreshable {
                        Task {
                            await loadProfile()
                        }
                    }
                }
                .sheet(isPresented: $showProfileEditingPage) {
                    ProfileEditingPageView(userProfile: userProfile)
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
                                await loadProfile()
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
            userProfile = try await manager.fetchMyUserProfile() ?? .placeholder()
            LOG.debug("Fetched user profile")
            
        } catch {
            errorMessage = error.localizedDescription.debugDescription
        }
    }
}

// #Preview {
//     
//     let userProfile = UserProfile.init(id: UUID(), first_name: "Nate", last_name: "dasd", user_name: "", biography: "ds", email: "dsd", date_of_birth: Date(), phone_number: "", created_at: Date())
//     
//     ProfileView(userProfile: .constant(userProfile))
// }
