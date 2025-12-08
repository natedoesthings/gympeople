//
//  UserProfileView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/24/25.
//

import SwiftUI

struct UserProfileView: View {
    @ObservedObject var userProfilesVM: ListViewModel<UserProfile>
    @State private var hasLoadedProfile: Bool = false
    @State private var hasLoadedAvatar: Bool = false
    
    var body: some View {
        Group {
            if let profile = userProfilesVM.items.first {
                ProfileContentView(userProfile: profile, hasLoadedAvatar: $hasLoadedAvatar)
            } else {
                Text("No profile found")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .overlay { if !hasLoadedProfile || !hasLoadedAvatar { ProgressView() } }
        .task {
            if !hasLoadedProfile {
                await userProfilesVM.load()
            }
            hasLoadedProfile = true
        }
        .listErrorAlert(vm: userProfilesVM, onRetry: { await userProfilesVM.refresh() })

    }
}

struct ProfileContentView: View {
    let userProfile: UserProfile
    @StateObject private var followersVM: ListViewModel<UserProfile>
    @StateObject private var followingVM: ListViewModel<UserProfile>
    @StateObject private var postsVM: ListViewModel<Post>
    @StateObject private var mentionsVM: ListViewModel<Post>
    @StateObject private var gymsVM: ListViewModel<Gym>
    @State private var profileTab: ProfileTab = .posts
    @State private var followed: Bool = false
    
    @Binding var hasLoadedAvatar: Bool
    
    init(userProfile: UserProfile, hasLoadedAvatar: Binding<Bool>) {
        self.userProfile = userProfile
        _hasLoadedAvatar = hasLoadedAvatar
        _followersVM = StateObject(wrappedValue: ListViewModel<UserProfile> {
            try await SupabaseManager.shared.fetchFollowers(for: userProfile.id)
        })
        _followingVM = StateObject(wrappedValue: ListViewModel<UserProfile> {
            try await SupabaseManager.shared.fetchFollowing(for: userProfile.id)
        })
        _postsVM = StateObject(wrappedValue: ListViewModel<Post> {
            try await SupabaseManager.shared.fetchPosts(for: userProfile.id)
        })
        _mentionsVM = StateObject(wrappedValue: ListViewModel<Post> {
            try await SupabaseManager.shared.fetchMentions(for: userProfile.id)
        })
        _gymsVM = StateObject(wrappedValue: ListViewModel<Gym> {
            try await SupabaseManager.shared.fetchGymMemberships(for: userProfile.id)
        })
    }

    var body: some View {
        HiddenScrollView {
            VStack(alignment: .leading, spacing: 4) {
                header()
                
                VStack(spacing: 4) {
                    profileTabBar

                    switch profileTab {
                    case .posts:
                        PostsView(postsVM: postsVM)
                    case .mentions:
                        PostsView(postsVM: mentionsVM)
                    }
                }
            }
            .padding()
            .task {
                followed = userProfile.is_following ?? false
            }
        }
    }

    @ViewBuilder
    private func header() -> some View {
        HStack(spacing: 30) {
            AvatarView(url: userProfile.pfp_url) {
                hasLoadedAvatar = true
            }
            .frame(width: 75, height: 75)
            
            VStack(alignment: .leading) {
                Text("\(userProfile.post_count)")
                Text("posts")
            }
            
            NavigationLink {
                UserProfileRowsView(userProfilesVM: followersVM)
            } label: {
                VStack(alignment: .leading) {
                    Text("\(userProfile.follower_count)")
                    Text("followers")
                }
                .foregroundStyle(.invertedPrimary)
            }
            
            
            NavigationLink {
                UserProfileRowsView(userProfilesVM: followingVM)
            } label: {
                VStack(alignment: .leading) {
                    Text("\(userProfile.following_count)")
                    Text("following")
                }
                .foregroundStyle(.invertedPrimary)
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
            GymTagsView(gymsVM: gymsVM)
        }
        .padding(.vertical, 15)
    }
    
    private var profileTabBar: some View {
        HStack(spacing: 40) {
            tabButton(.posts)
            tabButton(.mentions)
        }
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func tabButton(_ tab: ProfileTab) -> some View {
        Button {
            withAnimation(.spring(duration: 0.25)) {
                profileTab = tab
            }
        } label: {
            VStack(spacing: 6) {
                Text(tab.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(profileTab == tab ? .primary : .gray)

                if profileTab == tab {
                    Capsule()
                        .fill(Color.brandOrange)
                        .frame(width: 28, height: 3)
                        .transition(.scale)
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(width: 28, height: 3)
                }
            }
        }
    }
}
