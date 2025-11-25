//
//  FeedView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/24/25.
//

import SwiftUI

struct FeedView: View {
    let manager = SupabaseManager.shared
    @State private var userProfile: UserProfile?
    @State private var nearbyPosts: [NearbyPost]?
    @State private var showPostView: Bool = false
    @State private var fetched: Bool = false
    
    var body: some View {
        ScrollView {
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
                
                if let posts = nearbyPosts {
                    ForEach(posts) { post in
                        PostCard(
                                post: Post(
                                    id: post.post_id,
                                    user_id: post.post_user_id,
                                    content: post.content,
                                    created_at: post.created_at
                                ),
                                displayName: post.displayName,
                                username: post.author_user_name,
                                avatarURL: post.author_pfp_url,
                                feed: true
                            )
                            .padding()
                            .padding(.vertical, -10)
                        
                        Divider()
                    }
                } else {
                    // TODO: account for no posts nearby
                    Text("No posts nearby.")
                }
            }
        }
        .refreshable {
            Task {
                userProfile = try await manager.fetchMyUserProfile()
                nearbyPosts = try await manager.fetchNearbyPosts()
            }
        }
        .task {
            Task {
                if !fetched {
                    userProfile = try await manager.fetchMyUserProfile()
                    nearbyPosts = try await manager.fetchNearbyPosts()
                }
                
                fetched = true
            }
        }
        .sheet(isPresented: $showPostView) {
            PostView()
        }
        
    }
}
