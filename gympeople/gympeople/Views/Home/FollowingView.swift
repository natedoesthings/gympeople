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
            if followingPostsVM.isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 400)
            } else if followingPostsVM.items.isEmpty {
                // Empty State
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color("BrandOrange").opacity(0.6))
                    
                    VStack(spacing: 12) {
                        Text("No Posts from Following")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Follow people to see their posts here. Check out the Discover tab to find people!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    NavigationLink {
                        SearchView()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "magnifyingglass")
                            Text("Find People")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(Color("BrandOrange"))
                        .clipShape(Capsule())
                        .shadow(color: Color("BrandOrange").opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 500)
            } else {
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
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80)
        }
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
