//
//  ExploreView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/24/25.
//

import SwiftUI

struct ExploreView: View {
    @ObservedObject var nearbyPostsVM: ListViewModel<Post>
    @ObservedObject var userProfilesVM: ListViewModel<UserProfile>
    @State private var showPostView: Bool = false
    @State private var selectedPost: Post?
    
    var body: some View {
        HiddenScrollView {
            if nearbyPostsVM.isLoading || userProfilesVM.isLoading {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 400)
            } else if nearbyPostsVM.items.isEmpty {
                // Empty State
                VStack(spacing: 24) {
                    Spacer()
                    
                    Image(systemName: "text.bubble.fill")
                        .font(.system(size: 64))
                        .foregroundStyle(Color("BrandOrange").opacity(0.6))
                    
                    VStack(spacing: 12) {
                        Text("No Posts Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("Be the first to share something with people nearby!")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    
                    Button {
                        showPostView = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                            Text("Create Post")
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
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80)
        }
        .task {
            if !nearbyPostsVM.fetched {
                await nearbyPostsVM.load()
            }
        }
        .listErrorAlert(vm: nearbyPostsVM, onRetry: { await nearbyPostsVM.refresh() })
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
