//
//  PostCard.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/22/25.
//

import SwiftUI

struct PostCard: View {
    @StateObject private var userProfileVM: ListViewModel<UserProfile>
    @State private var showEditingPost: Bool = false
    @State private var showDeletingAlert: Bool = false
    @State var post: Post

    var feed: Bool = false
    
    init(post: Post, feed: Bool = false) {
        _post = State(initialValue: post)
        self.feed = feed
        _userProfileVM = StateObject(wrappedValue: ListViewModel<UserProfile> {
            try await SupabaseManager.shared.fetchUserProfile(for: post.user_id)
        })
    }

    var body: some View {
        NavigationStack {
            HStack(alignment: .top, spacing: 12) {
                // Avatar
                if feed {
                    NavigationLink {
                        UserIdProfileView(userProfilesVM: userProfileVM)
                    } label: {
                        AvatarView(url: post.author_pfp_url)
                            .frame(width: 36, height: 36)
                    }
                } else {
                    AvatarView(url: post.author_pfp_url)
                        .frame(width: 36, height: 36)
                }
                
                // Main column
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(post.author_first_name + " " + post.author_last_name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Placeholder actions menu icon
                        Menu {
                            if feed {
                                Button {
                                    
                                } label: {
                                    Text("Report")
                                    Image(systemName: "exclamationmark.bubble")
                                }
                                
                            } else {
                                Button {
                                    showEditingPost = true
                                } label: {
                                    Text("Edit")
                                    Image(systemName: "pencil")
                                }
                                
                                Button {
                                    showDeletingAlert = true
                                } label: {
                                    Text("Delete")
                                    Image(systemName: "trash")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.caption)
                        }
                        
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text("@\(post.author_user_name)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        
                        Text("-")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(post.created_at, style: .relative) // e.g. “5m ago”
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text("ago")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    // Content
                    Text(post.content)
                        .font(.body)
                        .foregroundStyle(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    HStack(spacing: 40) {
                        Button {
                            Task {
                                if !post.is_liked {
                                    await SupabaseManager.shared.likePost(for: post.id)
                                } else {
                                    await SupabaseManager.shared.unlikePost(for: post.id)
                                }
                            }
                            
                            if !post.is_liked {
                                post.like_count += 1
                                post.is_liked = true
                            } else {
                                post.like_count -= 1
                                post.is_liked = false
                            }
                            
                        } label: {
                            HStack {
//                                let _ = print(post.like_count)
                                Image(systemName: post.is_liked ? "heart.fill" : "heart")
                                Text("\(post.like_count)")
                            }
                            .font(.caption)
                        }
                       
                        Button {
                            
                        } label: {
                            HStack {
                                Image(systemName: "message")
                                Text("\(post.comment_count)")
                            }
                            .font(.caption)
                        }
                        
                    }
                    .padding(.top, 10)
                }
            }
            .padding(.vertical, 10)
            .sheet(isPresented: $showEditingPost) {
                EditingPostView(post_id: post.id, content: post.content)
            }
            .alert(isPresented: $showDeletingAlert) {
                Alert(
                    title: Text("Delete Post"),
                    message: Text("Are you sure you want to delete this post? This action cannot be undone."),
                    primaryButton: .cancel(Text("Cancel")),
                    secondaryButton: .destructive(Text("Delete"), action: {
                        Task {
                            await SupabaseManager.shared.deletePost(post_id: post.id)
                        }
                    })
                )
            }
        }
    }
}

struct AvatarView: View {
    let url: String?

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: URL(string: url)) { phase in
                    switch phase {
                    case .empty:
                        placeholder
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        placeholder
                    @unknown default:
                        placeholder
                    }
                }
            } else {
                placeholder
            }
        }
        .clipShape(Circle())
    }

    private var placeholder: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFill()
            .foregroundStyle(Color.gray.opacity(0.6))
    }
}
