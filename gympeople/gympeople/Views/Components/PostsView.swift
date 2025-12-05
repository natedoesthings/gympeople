//
//  PostsView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/2/25.
//

import SwiftUI

struct PostsView: View {
    @ObservedObject var postsVM: ListViewModel<Post>
    @State private var selectedPost: Post?
    @State private var selectedDeletedPost: Post?
    @State private var showDeletingAlert: Bool = false
    
    var feed: Bool = false
    
    var body: some View {
        HiddenScrollView {
            LazyVStack {
                ForEach(postsVM.items, id: \.self) { post in
                    PostCard(
                        post: post,
                        feed: feed,
                        onCommentsTap: { selectedPost = post },
                        onDeleteTap: { selectedDeletedPost = post },
                        showDeletingAlert: $showDeletingAlert,
                    )
                    
                    Divider()
                }
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
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 100)
        }
//        .overlay { if postsVM.isLoading { ProgressView() } }
        .task {
            if !postsVM.fetched {
                await postsVM.load()
            }
        }
        .listErrorAlert(vm: postsVM, onRetry: { await postsVM.refresh() })
        .alert(isPresented: $showDeletingAlert) {
            Alert(
                title: Text("Delete Post"),
                message: Text("Are you sure you want to delete this post? This action cannot be undone."),
                primaryButton: .cancel(Text("Cancel")),
                secondaryButton: .destructive(Text("Delete"), action: {
                    Task {
                        if let post = selectedDeletedPost {
                            await SupabaseManager.shared.deletePost(post_id: post.id)
                        }
                    }
                })
            )
        }
    }
}
