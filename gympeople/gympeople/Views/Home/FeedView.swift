//
//  FeedView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/24/25.
//

import SwiftUI

struct FeedView: View {
    let manager = SupabaseManager.shared
    @StateObject var nearbyPostsVM: ListViewModel<NearbyPost>
    @State private var userProfile: UserProfile?
//    @State private var nearbyPosts: [NearbyPost]?
    @State private var showPostView: Bool = false
    @State private var fetched: Bool = false
    
    var body: some View {
        HiddenScrollView {
            LazyVStack {
                // Wanna say hi?
                Button {
                    showPostView = true
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        // Avatar
                        if let userProfile = userProfile {
                            AvatarView(url: userProfile.pfp_url)
                                .frame(width: 36, height: 36)
                            
                            // Main column
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .firstTextBaseline, spacing: 6) {
                                    Text("\(userProfile.first_name) \(userProfile.last_name)")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .lineLimit(1)
                                        .foregroundStyle(.invertedPrimary)
                                    
                                    Spacer()
                                    
                                }
                                
                                // Content
                                Text("Say something!")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .foregroundStyle(Color(.systemGray))
                            }
                        }
                        
                    }
                    .padding()
                }
                
                Divider()
                
//                if let posts = nearbyPosts {
                    ForEach(nearbyPostsVM.items) { post in
                        
                        // TODO: https://github.com/natedoesthings/gympeople/issues/42
//                        let _ = print(post.is_liked)
//                        let _ = print(post.is_liked)
//                        
                        PostCard(
                                post: Post(
                                    id: post.post_id,
                                    user_id: post.post_user_id,
                                    content: post.content,
                                    created_at: post.created_at,
                                    updated_at: post.updated_at,
                                    like_count: post.like_count,
                                    comment_count: post.comment_count,
                                    is_liked: post.is_liked,
                                    gym_id: post.gym_id
                                ),
                                displayName: post.author_first_name + post.author_last_name,
                                username: post.author_user_name,
                                avatarURL: post.author_pfp_url,
                                feed: true
                            )
                            .padding()
                            .padding(.vertical, -10)
                        
                        Divider()
                    }
//                } else {
//                    // TODO: account for no posts nearby
//                    Text("No posts nearby.")
//                }
            }
        }
        .overlay { if nearbyPostsVM.isLoading { ProgressView() } }
        .task {
            Task {
                if !fetched {
                    userProfile = try await manager.fetchMyUserProfile()
//                    nearbyPosts = try await manager.fetchNearbyPosts()
                    nearbyPostsVM.load()
                }
                
                fetched = true
            }
        }
        .alert(isPresented: Binding(
                    get: { nearbyPostsVM.currentError != nil },
                    set: { _ in nearbyPostsVM.currentError = nil }
                )) {
                    let info = ErrorPresenter.message(for: nearbyPostsVM.currentError ?? .unexpected)
                    return Alert(
                        title: Text(info.title),
                        message: Text(info.detail),
                        dismissButton: .default(Text(info.action ?? "OK")) {
                            if info.action != nil { nearbyPostsVM.refresh() }
                        }
                    )
                }
        .refreshable {
            Task {
                userProfile = try await manager.fetchMyUserProfile()
//                nearbyPosts = try await manager.fetchNearbyPosts()
                nearbyPostsVM.refresh()
            }
        }
        
        .sheet(isPresented: $showPostView) {
            PostView()
        }
        
    }
}
