//
//  FeedView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/24/25.
//

import SwiftUI

struct FeedView: View {
    @ObservedObject var nearbyPostsVM: ListViewModel<Post>
    @ObservedObject var userProfilesVM: ListViewModel<UserProfile>
    @State private var showPostView: Bool = false
    @State private var selectedPost: Post?
    
    var body: some View {
        HiddenScrollView {
            LazyVStack {
                // Wanna say hi?
                Button {
                    showPostView = true
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        // Avatar
                        if let userProfile = userProfilesVM.items.first {
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
                ForEach(nearbyPostsVM.items) { post in
                    // TODO: https://github.com/natedoesthings/gympeople/issues/42
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
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80)
        }
        .overlay { if nearbyPostsVM.isLoading || userProfilesVM.isLoading { ProgressView() } }
//        .loading(nearbyPostsVM.isLoading || userProfilesVM.isLoading)
        .task {
            if !userProfilesVM.fetched && !nearbyPostsVM.fetched {
                await userProfilesVM.load()
                await nearbyPostsVM.load()
            }
        }
        .listErrorAlert(vm: nearbyPostsVM, onRetry: { await nearbyPostsVM.refresh() })
        .listErrorAlert(vm: userProfilesVM, onRetry: { await userProfilesVM.refresh() })
        .refreshable {
                await userProfilesVM.refresh()
                await nearbyPostsVM.refresh()
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
        .sheet(isPresented: $showPostView) {
            PostView()
        }
        
    }
}
