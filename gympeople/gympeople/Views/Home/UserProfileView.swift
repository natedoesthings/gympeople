//
//  UserProfileView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/24/25.
//

import SwiftUI

struct UserIdProfileView: View {
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
    @StateObject private var postsVM: ListViewModel<Post>
    @StateObject private var mentionsVM: ListViewModel<Post>
    @StateObject private var gymsVM: ListViewModel<Gym>
    @State private var profileTab: ProfileTab = .posts
    @State private var followed: Bool = false
    
    @Binding var hasLoadedAvatar: Bool
    
    init(userProfile: UserProfile, hasLoadedAvatar: Binding<Bool>) {
        self.userProfile = userProfile
        _hasLoadedAvatar = hasLoadedAvatar
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
                PostsView(postsVM: postsVM, feed: true)
            case .mentions:
                PostsView(postsVM: mentionsVM, feed: true)
            }
        }
        .padding()
        .task {
            followed = userProfile.is_following ?? false
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
            GymTagsView(gymsVM: gymsVM)
        }
        .padding(.vertical, 15)
    }
}
