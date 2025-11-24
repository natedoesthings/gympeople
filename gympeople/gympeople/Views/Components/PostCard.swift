//
//  PostCard.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/22/25.
//

import SwiftUI

struct PostCard: View {
    let post: Post
    let displayName: String
    let username: String
    let avatarURL: String?
    var feed: Bool = false

    var body: some View {
        NavigationStack {
            HStack(alignment: .top, spacing: 12) {
                // Avatar
                if feed {
                    NavigationLink {
                        UserIdProfileView(userId: post.user_id)
                    } label: {
                        AvatarView(url: avatarURL)
                            .frame(width: 36, height: 36)
                    }
                } else {
                    AvatarView(url: avatarURL)
                        .frame(width: 36, height: 36)
                }
                
                
                // Main column
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text(displayName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        // Placeholder actions menu icon
                        Button {
                            
                        } label: {
                            Image(systemName: "ellipsis")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                    }
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text("@\(username)")
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
                }
            }
            .padding(.vertical, 10)
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

#Preview {
    let posts = [Post(id: UUID(), user_id: UUID(), content: "Morning cardio at the track. 5K in 24:10. Progress! Also started incorporating some mobility drills.", created_at: Date().addingTimeInterval(-60 * 7)),
                 Post(id: UUID(), user_id: UUID(), content: "Morning cardio at the track. 5K in 24:10. Progress! Also started incorporating some mobility drills.", created_at: Date().addingTimeInterval(-60 * 7)),
                 Post(id: UUID(), user_id: UUID(), content: "Morning cardio at the track. 5K in 24:10. Progress! Also started incorporating some mobility drills.", created_at: Date().addingTimeInterval(-60 * 7))]
    
    ScrollView {
        LazyVStack(spacing: 0) {
            ForEach(posts, id: \.self) { post in
                PostCard(
                    post: post,
                    displayName: "Nathanael Tesfaye",
                    username: "nate",
                    avatarURL: "https://picsum.photos/seed/nate/200"
                )
                Divider()
            }
            
        }

    }
}
