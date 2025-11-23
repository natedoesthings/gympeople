//
//  PostCard.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/22/25.
//

import SwiftUI

struct PostCard: View {
    // Inputs you can bind to real data later
    let post: Post
    let displayName: String
    let username: String
    let avatarURL: URL?
//    let createdAt: String
//    let content: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            AvatarView(url: avatarURL)

            // Main column
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .lineLimit(1)

                    Text("@\(username)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)

                    Text("•")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(post.created_at, style: .relative) // e.g. “5m ago”
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    // Placeholder actions menu icon
                    Image(systemName: "ellipsis")
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
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

private struct AvatarView: View {
    let url: URL?

    var body: some View {
        Group {
            if let url {
                AsyncImage(url: url) { phase in
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
        .frame(width: 44, height: 44)
        .clipShape(Circle())
    }

    private var placeholder: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .scaledToFill()
            .foregroundStyle(Color.gray.opacity(0.6))
    }
}

//#Preview {
//    ScrollView {
//        VStack(spacing: 0) {
//            PostCard(
//                displayName: "Nathanael Tesfaye",
//                username: "nate",
//                avatarURL: URL(string: "https://picsum.photos/seed/nate/200"),
//                createdAt: "", // 7 minutes ago
//                content: "Hit a new PR on deadlifts today! 405 lbs for a clean single. Feeling strong 💪 Any tips for improving form on the negative?"
//            )
//            Divider()
//
//            PostCard(
//                displayName: "Jane Doe",
//                username: "jane_d",
//                avatarURL: nil, // shows placeholder
//                createdAt: "", // 3 hours ago
//                content: "Morning cardio at the track. 5K in 24:10. Progress! Also started incorporating some mobility drills."
//            )
//            
//            Divider()
//
//            PostCard(
//                displayName: "Marcus Lee",
//                username: "marcus",
//                avatarURL: URL(string: "https://picsum.photos/seed/marcus/200"),
//                createdAt: "", // 2 days ago
//                content: "Upper body push day: bench 3x5 @ 225, OHP 3x5 @ 135, dips 3x10. Feeling dialed in."
//            )
//        }
//        .padding(.top)
//    }
//}
