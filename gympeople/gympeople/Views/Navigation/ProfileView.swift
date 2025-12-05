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
    @ObservedObject var userProfilesVM: ListViewModel<UserProfile>
    @ObservedObject var postsVM: ListViewModel<Post>
    @ObservedObject var mentionsVM: ListViewModel<Post>
    @ObservedObject var gymsVM: ListViewModel<Gym>

    @State private var errorMessage: String?
    
    @State private var photosPickerItem: PhotosPickerItem?
    @State private var hasLoadedProfile: Bool = false
    @State private var hasLoadedAvatar: Bool = false
    
    @State private var showProfileEditingPage: Bool = false
    @State private var profileTab: ProfileTab = .posts
    @State private var outerDisabled = false
    
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
                            HiddenScrollView(.horizontal) {
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
                        
                        Picker("", selection: $profileTab) {
                            ForEach(ProfileTab.allCases) { tab in
                                Text(tab.rawValue).tag(tab)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        switch profileTab {
                        case .posts:
                            PostsView(postsVM: postsVM)
                            .gesture(
                                DragGesture()
                                    .onChanged { _ in outerDisabled = true }
                                    .onEnded { _ in outerDisabled = false }
                            )
                            .frame(height: 500)
                        case .mentions:
                            Text("Your mentions")
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
        await userProfilesVM.load()
        await gymsVM.load()
        await postsVM.load()
        await mentionsVM.load()
        hasLoadedProfile = true
    }
}
