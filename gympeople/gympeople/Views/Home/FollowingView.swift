//
//  FollowingView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/23/25.
//

import SwiftUI

struct FollowingView: View {
    @State private var followingPosts: [FollowingPost]?
    @State private var showPostView: Bool = false
    @State private var fetched: Bool = false
    
    var body: some View {
        HiddenScrollView {
            LazyVStack {
                if let posts = followingPosts {
                    ForEach(posts) { post in
                        PostCard(
                            post: Post(
                                id: post.post_id,
                                user_id: post.post_user_id,
                                content: post.content,
                                created_at: post.created_at,
                                updated_at: post.updated_at,
                                like_count: post.like_count,
                                comment_count: post.comment_count
                            ),
                            displayName: post.first_name + " " + post.last_name,
                            username: post.user_name,
                            avatarURL: post.pfp_url,
                            feed: true
                        )
                        .padding()
                        .padding(.vertical, -10)
                        
                        Divider()
                    }
                } else {
                    // TODO: account for no followers
                    Text("Follow People to see posts here!")
                }
            }
        }
        .refreshable {
            Task {
                followingPosts = await SupabaseManager.shared.fetchFollowingPosts()
            }
        }
        .task {
            Task {
                if !fetched {
                    followingPosts = await SupabaseManager.shared.fetchFollowingPosts()
                }
                fetched = true
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
