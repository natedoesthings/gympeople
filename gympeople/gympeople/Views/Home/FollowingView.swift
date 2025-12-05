//
//  FollowingView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/23/25.
//

import SwiftUI

struct FollowingView: View {
    @ObservedObject var followingPostsVM: ListViewModel<Post>
    @State private var showPostView: Bool = false
    @State private var selectedPost: Post?
    
    var body: some View {
        HiddenScrollView {
            LazyVStack {
                ForEach(followingPostsVM.items) { post in
                    PostCard(
                        post: post,
                        feed: true,
                        onCommentsTap: { selectedPost = post }
                    )
                    .padding()
                    .padding(.vertical, -10)
                    
                    Divider()
                }
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .overlay { if followingPostsVM.isLoading { ProgressView() } }
        .task {
            Task {
                if !followingPostsVM.fetched {
                    await followingPostsVM.load()
                }
            }
        }
        .listErrorAlert(vm: followingPostsVM, onRetry: { await followingPostsVM.refresh() })
        .refreshable {
            Task {
                await followingPostsVM.refresh()
            }
        }
        .sheet(item: $selectedPost) { post in
            CommentsView(
                commentsVM: ListViewModel<Comment> {
                    try await SupabaseManager.shared.fetchComments(for: post.id)
                },
                post_id: post.id
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackgroundInteraction(.enabled)
        }
    }
}
