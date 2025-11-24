//
//  UserProfileView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/24/25.
//

import SwiftUI

struct UserProfileView: View {
    let manager = SupabaseManager.shared
    let userProfile: UserProfile
    @State private var posts: [Post]?
    @State private var hasLoadedProfile: Bool = false
    @State private var profileTab: ProfileTab = .posts
    
    var body: some View {
        ProfileContentView(
            userProfile: userProfile,
            posts: posts,
            profileTab: $profileTab
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear(perform: loadOnce)
    }
    
    private func loadOnce() {
        guard !hasLoadedProfile else { return }
        hasLoadedProfile = true
        Task { await loadProfile() }
    }

    private func loadProfile() async {
        do {
            // Fetch posts
            LOG.debug("Fetching users posts")
            posts = try await manager.fetchPosts(for: userProfile.id)
            LOG.debug("Fetched users posts")
        } catch {
            LOG.error(error.localizedDescription.debugDescription)
        }
    }
}

struct UserIdProfileView: View {
    let userId: UUID
    let manager = SupabaseManager.shared
    
    @State private var userProfile: UserProfile?
    @State private var posts: [Post]?
    @State private var hasLoadedProfile: Bool = false
    @State private var profileTab: ProfileTab = .posts
    
    var body: some View {
        VStack {
            if let userProfile = userProfile {
                ProfileContentView(
                    userProfile: userProfile,
                    posts: posts,
                    profileTab: $profileTab
                )
            } else {
                ProgressView("Loading Profile...")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .onAppear {
            if !hasLoadedProfile {
                Task {
                    await loadProfile()
                }
                hasLoadedProfile = true
            }
        }
        
    }
    
    private func loadProfile() async {
        do {
            // Fetch posts
            LOG.debug("Fetching users posts")
            posts = try await manager.fetchPosts(for: userId)
            LOG.debug("Fetched users posts")
            
            // Fetch profile
            LOG.debug("Fetching user profile")
            userProfile = try await manager.fetchUserProfile(for: userId)
            LOG.debug("Fetched user profile")
    
        } catch {
            LOG.error(error.localizedDescription.debugDescription)
        }
    }
}

private struct ProfileContentView: View {
    let userProfile: UserProfile
    let posts: [Post]?
    @Binding var profileTab: ProfileTab

    var body: some View {
        VStack {
            header

            Picker("", selection: $profileTab) {
                ForEach(ProfileTab.allCases) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            switch profileTab {
            case .posts:
                ScrollView {
                    LazyVStack {
                        if let posts = posts {
                            ForEach(posts, id: \.self) { post in
                                PostCard(
                                    post: post,
                                    displayName: userProfile.first_name,
                                    username: userProfile.user_name,
                                    avatarURL: userProfile.pfp_url
                                )
                                .padding()

                                Divider()
                            }
                        }
                    }
                }
            case .mentions:
                Text("Mentions")
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            AvatarView(url: userProfile.pfp_url)
                .frame(width: 75, height: 75)

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

            VStack(alignment: .leading, spacing: 15) {
                ScrollView(.horizontal) {
                    if let gyms = userProfile.gym_memberships {
                        HStack {
                            
                            ForEach(gyms, id: \.self) { gym in
                                GymTagButton(gymTagType: .gym(gym: gym))
                            }
                            
                        }
                        .padding(1)
                    }
                }
            }
            .padding(.vertical, 15)
        }
        .padding()
    }
}
