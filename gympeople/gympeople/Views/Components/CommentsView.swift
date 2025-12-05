//
//  CommentsView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/3/25.
//

import SwiftUI

struct CommentsView: View {
    @ObservedObject var commentsVM: ListViewModel<Comment>
    
    // Reply + parent logic
    @State private var parentCommentID: UUID?
    @State private var text: String = ""
    @FocusState private var isReplying: Bool
    let post_id: UUID
    
    var body: some View {
        VStack(spacing: 0) {
            // Comments list
            HiddenScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    if !commentsVM.items.isEmpty {
                        ForEach(commentsVM.items, id: \.self) { comment in
                            CommentCard(
                                isReplying: $isReplying,
                                comment: comment,
                                parentCommentID: $parentCommentID
                            )
                        }
                    } else {
                        VStack {
                            Text("Be the first to comment.")
                        }
                    }
                }
            }
            .overlay {
                if commentsVM.isLoading { ProgressView() }
            }
            .task {
                if !commentsVM.fetched {
                    await commentsVM.load()
                }
            }
            .listErrorAlert(vm: commentsVM, onRetry: { await commentsVM.refresh() })
            
            
            // ➤ Comment Textfield Section
            commentInputBar
                .padding()
                .background(Color(.systemBackground))
        }
        .padding()

    }
    
    
    // MARK: - Submit Comment / Reply
    private func submitComment() async {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        do {
            if let parent = parentCommentID {
                try await SupabaseManager.shared.createComment(for: post_id, with: text, parent: parent)
            } else {
                try await SupabaseManager.shared.createComment(for: post_id, with: text)
            }
        } catch {
            
        }
        
        // Reset
        text = ""
        parentCommentID = nil
        isReplying = false
        
        await commentsVM.refresh()
    }
    
    // MARK: - Textfield UI
    private var commentInputBar: some View {
        HStack(spacing: 12) {
            TextField(parentCommentID != nil ? "Replying..." : "Add a comment...",
                      text: $text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.vertical, 12)
            
            // Submit Button – only appears if text is non-empty
            if !text.trimmingCharacters(in: .whitespaces).isEmpty {
                Button {
                    Task { await submitComment() }
                } label: {
                    Text("Send")
                        .fontWeight(.semibold)
                }
            } else {
                if parentCommentID != nil {
                    Button {
                        parentCommentID = nil
                        isReplying = false
                    } label: {
                        Image(systemName: "x.circle")
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .padding(.horizontal)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 2)
                
        )
    }
}


#Preview {
    CommentsView(commentsVM: ListViewModel<Comment>(fetcher: {return []}), post_id: UUID())
}
