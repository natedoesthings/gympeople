//
//  ProfileView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    @StateObject private var followersVM = ListViewModel<UserProfile>(fetcher: {
        try await SupabaseManager.shared.fetchMyFollowers()
    })
    @StateObject private var followingVM = ListViewModel<UserProfile>(fetcher: {
        try await SupabaseManager.shared.fetchMyFollowing()
    })
    @StateObject var userProfilesVM = ListViewModel<UserProfile>(fetcher: { try await SupabaseManager.shared.fetchMyUserProfile(refresh: true) })
    
    @StateObject var postsVM = ListViewModel<Post>(fetcher: { try await SupabaseManager.shared.fetchMyPosts() })
    
    @StateObject var mentionsVM = ListViewModel<Post>(fetcher: { try await SupabaseManager.shared.fetchMyMentions() })
    
    @StateObject var gymsVM = ListViewModel<Gym>(fetcher: { try await SupabaseManager.shared.fetchMyGymMemberships() })
    
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var hasLoadedProfile: Bool = false
    @State private var hasLoadedAvatar: Bool = false
    @State private var refreshID = UUID()
    
    @State private var showProfileEditingPage: Bool = false
    @State private var profileTab: ProfileTab = .posts
    
    
    
    var body: some View {
        ZStack {
            if hasLoadedProfile {
                profileContent
                    .opacity(hasLoadedAvatar ? 1 : 0)
            }
            
            if !hasLoadedProfile || !hasLoadedAvatar {
                ProgressView("Loading Profile...")
            }
        }
        .onAppear {
            if !hasLoadedProfile {
                Task {
                    await loadProfile()
                }
            }
        }
        .onChange(of: photosPickerItem) { _, _ in
            Task {
                if let photosPickerItem {
                    if let data = try? await photosPickerItem.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: data) {
                            do {
                                try await SupabaseManager.shared.uploadProfilePicture(image)
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
    
    private var profileContent: some View {
        // Profile picture displayer and selector
        NavigationStack {
            HiddenScrollView {
                VStack(alignment: .leading, spacing: 4) {
                    if let userProfile = userProfilesVM.items.first {
                        // Profile Picture
                        HStack(spacing: 30) {
                            PhotosPicker(selection: $photosPickerItem, matching: .images) {
                                ZStack(alignment: .bottomTrailing) {
                                    AvatarView(url: userProfile.pfp_url) {
                                        hasLoadedAvatar = true
                                    }
                                    .id(refreshID)
                                    .frame(width: 75, height: 75)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                    )
                                    
                                    // Edit badge
                                    Circle()
                                        .fill(Color.invertedPrimary)
                                        .frame(width: 26, height: 26)
                                        .overlay(
                                            Image(systemName: "pencil")
                                                .font(.system(size: 12, weight: .medium))
                                                .foregroundColor(.standardPrimary)
                                        )
                                        .offset(x: 4, y: 4)  // small outward offset
                                }
                                .frame(width: 75, height: 75)
                            }
                            
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
                            HiddenScrollView(.horizontal, trackScrollForTabBar: false) {
                                HStack {
                                    if !gymsVM.items.isEmpty {
                                        ForEach(gymsVM.items, id: \.self) { gym in
                                            Button {
                                                showProfileEditingPage = true
                                            } label: {
                                                GymTagButton(gymTagType: .gym(gym: gym))
                                            }
                                        }
                                        
                                        NavigationLink {
                                            GymEditingView(gym_memberships: $gymsVM.items)
                                        } label: {
                                            GymTagButton(gymTagType: .plus)
                                        }
                                    } else {
                                        NavigationLink {
                                            GymEditingView(gym_memberships: $gymsVM.items)
                                        } label: {
                                            GymTagButton(gymTagType: .none)
                                        }
                                        
                                    }
                                }
                                .padding(1)
                            }
                        }
                        .padding(.vertical, 15)
                        
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
                                if let userProfile = userProfilesVM.items.first {
                                    ProfileSettingsPageView(userProfile: userProfile)
                                }
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                            }
                        }
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }
            .refreshable {
                await loadProfile()
            }
        }
        .sheet(isPresented: $showProfileEditingPage) {
            if let userProfile = userProfilesVM.items.first {
                ProfileEditingPageView(userProfile: userProfile, memberships: gymsVM.items)
            }
        }
    }
    
    @MainActor
    private func loadProfile() async {
        hasLoadedAvatar = false
        refreshID = UUID()
        await userProfilesVM.load()
        await gymsVM.load()
        hasLoadedProfile = true
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
            profileTab = tab
        } label: {
            VStack(spacing: 6) {
                Text(tab.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(profileTab == tab ? .primary : .gray)

                Capsule()
                    .fill(profileTab == tab ? Color.brandOrange : Color.clear)
                    .frame(width: 28, height: 3)
            }
        }
    }
}
