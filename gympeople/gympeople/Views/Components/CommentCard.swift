//
//  CommentCard.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/3/25.
//

import SwiftUI

struct CommentCard: View {
    @StateObject private var repliesVM: ListViewModel<Comment>
    var isReplying: FocusState<Bool>.Binding
    @State var comment: Comment
    @Binding var parentCommentID: UUID?
    
    @State private var showReplies: Bool = false
    @State private var hasLoadedReplies: Bool = false
    
    init(
        isReplying: FocusState<Bool>.Binding,
        comment: Comment,
        parentCommentID: Binding<UUID?> = .constant(nil)
    ) {
        self.isReplying = isReplying
        _comment = State(initialValue: comment)
        _repliesVM = StateObject(
            wrappedValue: ListViewModel<Comment> {
                try await SupabaseManager.shared.fetchReplies(for: comment.id)
            }
        )
        _parentCommentID = parentCommentID
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // MAIN COMMENT ROW
            HStack(alignment: .top, spacing: 12) {
                // Avatar
                AvatarView(url: comment.author_pfp_url)
                .frame(width: 36, height: 36)
                .clipShape(Circle())
                
                // Comment Content
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text(comment.author_user_name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(timeAgo(comment.created_at))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Text(comment.content)
                        .font(.subheadline)
                    
                    // Reply + View replies
                    HStack(spacing: 12) {
                        Button {
                            parentCommentID = comment.id
                            isReplying.wrappedValue = true
                        } label: {
                            Text("Reply")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        if comment.replies_count > 0 {
                            Button {
                                Task {
                                    if !hasLoadedReplies {
                                        await repliesVM.load()
                                        hasLoadedReplies = true
                                    }
//                                    withAnimation(.easeInOut) {
//                                        showReplies.toggle()
//                                    }
                                    showReplies.toggle()
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(showReplies ? "Hide replies" : "View replies")
                                    Text("(\(comment.replies_count))")
                                }
                                .font(.caption)
                                .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding(.top, 2)
                }
                
                Spacer()
                
                // Likes
                Button {
                    Task {
                        if !comment.is_liked {
                            await SupabaseManager.shared.likeComment(for: comment.id)
                            comment.like_count += 1
                            comment.is_liked = true
                        } else {
                            await SupabaseManager.shared.unlikeComment(for: comment.id)
                            comment.like_count -= 1
                            comment.is_liked = false
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: comment.is_liked ? "heart.fill" : "heart")
                            .foregroundColor(comment.is_liked ? .red : .primary)
                        
                        if comment.like_count > 0 {
                            Text("\(comment.like_count)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.vertical, 6)
            
            // REPLIES LIST (INDENTED)
            if showReplies, !repliesVM.items.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(repliesVM.items, id: \.self) { reply in
                        ReplyCard(reply: reply)
                    }
                }
//                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(.bottom)
    }
}


struct ReplyCard: View {
    @State var reply: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Indent to align under main comment text, not avatar
            Spacer()
                .frame(width: 36 + 12) // same as avatar + spacing
            
            HStack(alignment: .top, spacing: 8) {
                AsyncImage(url: URL(string: reply.author_pfp_url ?? "")) { img in
                    img.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(Color.gray.opacity(0.3))
                }
                .frame(width: 28, height: 28)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(reply.author_user_name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Text(timeAgo(reply.created_at))
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Text(reply.content)
                        .font(.subheadline)
                }
                
                Spacer()
                
                // Likes
                Button {
                    Task {
                        if !reply.is_liked {
                            await SupabaseManager.shared.likeComment(for: reply.id)
                            reply.like_count += 1
                            reply.is_liked = true
                        } else {
                            await SupabaseManager.shared.unlikeComment(for: reply.id)
                            reply.like_count -= 1
                            reply.is_liked = false
                        }
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: reply.is_liked ? "heart.fill" : "heart")
                            .foregroundColor(reply.is_liked ? .red : .primary)
                        
                        if reply.like_count > 0 {
                            Text("\(reply.like_count)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
        }
    }
}
