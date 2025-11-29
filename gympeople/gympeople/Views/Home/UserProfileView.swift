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
    @State private var memberships: [Gym]?
    @State private var hasLoadedProfile: Bool = false
    @State private var profileTab: ProfileTab = .posts
    
    var body: some View {
        ProfileContentView(
            userProfile: userProfile,
            posts: posts,
            memberships: memberships,
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
            // Fetch memberships
            LOG.debug("Fetching users memberships")
            memberships = await manager.fetchGymMemberships(for: userProfile.id)
            
            // Fetch posts
            LOG.debug("Fetching users posts")
            posts = try await manager.fetchPosts(for: userProfile.id)
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
    @State private var memberships: [Gym]?
    @State private var hasLoadedProfile: Bool = false
    @State private var profileTab: ProfileTab = .posts
    
    var body: some View {
        VStack {
            if let userProfile = userProfile {
                ProfileContentView(
                    userProfile: userProfile,
                    posts: posts,
                    memberships: memberships,
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
            // Fetch memberships
            LOG.debug("Fetching users memberships")
            memberships = await manager.fetchGymMemberships(for: userId)
            
            // Fetch posts
            LOG.debug("Fetching users posts")
            posts = try await manager.fetchPosts(for: userId)
            
            // Fetch profile
            LOG.debug("Fetching user profile")
            userProfile = try await manager.fetchUserProfile(for: userId)
        } catch {
            LOG.error(error.localizedDescription.debugDescription)
        }
    }
}

private struct ProfileContentView: View {
    let userProfile: UserProfile
    let posts: [Post]?
    let memberships: [Gym]?
    @Binding var profileTab: ProfileTab
    @State private var followed: Bool = false

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 4) {
                header()
                
                Picker("", selection: $profileTab) {
                    ForEach(ProfileTab.allCases) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                switch profileTab {
                case .posts:
                    HiddenScrollView {
                        LazyVStack {
                            if let posts = posts {
                                ForEach(posts, id: \.self) { post in
                                    PostCard(
                                        post: post,
                                        displayName: userProfile.first_name,
                                        username: userProfile.user_name,
                                        avatarURL: userProfile.pfp_url,
                                        likeState: false
                                    )
                                    
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
        .padding()
        .onAppear {
            Task {
                followed = try await SupabaseManager.shared.checkIfFollowing(userId: userProfile.id)
            }
        }
    }

    @ViewBuilder
    private func header() -> some View {
        HStack(spacing: 30) {
            AvatarView(url: userProfile.pfp_url)
                .frame(width: 75, height: 75)
            
            VStack(alignment: .leading) {
                Text("\(userProfile.post_count)")
                Text("posts")
            }
            
            VStack(alignment: .leading) {
                Text("\(userProfile.follower_count)")
                Text("followers")
            }
            
            VStack(alignment: .leading) {
                Text("\(userProfile.following_count)")
                Text("following")
            }
        }

        HStack {
            Group {
                Text(userProfile.first_name)
                Text(userProfile.last_name)
            }
            .padding(.top, 5)
            .font(.title3)
            .fontWeight(.semibold)
            
            Spacer()
            
            Button {
                Task {
                    if followed {
                        await SupabaseManager.shared.removeFollowee(userId: userProfile.id)
                        followed = false
                        
                    } else {
                        await SupabaseManager.shared.addFollowee(userId: userProfile.id)
                        followed = true
                    }
                }
            } label: {
                Text(followed ? "Unfollow" : "Follow" )
                    .foregroundStyle(.invertedPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.brandOrange)
                    .cornerRadius(12)
            }
            .frame(width: 150)
        }
        

        VStack(alignment: .leading, spacing: 5) {
            Text("@\(userProfile.user_name)")
            if let bio = userProfile.biography {
                if !bio.isEmpty {
                    Text("\(bio)")
                }
            }
        }
        .font(.caption)
        .foregroundStyle(Color.standardSecondary)

        VStack(alignment: .leading, spacing: 15) {
            HiddenScrollView(.horizontal) {
                if let memberships = memberships {
                    HStack {
                        ForEach(memberships, id: \.self) { gym in
                            GymTagButton(gymTagType: .gym(gym: gym))
                        }
                        
                    }
                    .padding(1)
                }
            }
        }
        .padding(.vertical, 15)
    }
}


#Preview {
    UserProfileView(userProfile: .placeholder())
}
