//
//  CommentService.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import Foundation
import Supabase

protocol CommentServiceProtocol {
    func createComment(for postId: UUID, with comment: String, parentId: UUID?) async throws
    func fetchComments(for postId: UUID) async throws -> [Comment]
    func fetchReplies(for commentId: UUID) async throws -> [Comment]
}

class CommentService: CommentServiceProtocol {
    private let client: SupabaseClient
    private let rpc: RPCRepository
    
    init(client: SupabaseClient) {
        self.client = client
        self.rpc = RPCRepository(client: client)
    }
    
    func createComment(for postId: UUID, with comment: String, parentId: UUID? = nil) async throws {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }
        
        let data: [String: AnyEncodable] = [
            "post_id": AnyEncodable(postId),
            "parent_comment_id": AnyEncodable(parentId),
            "user_id": AnyEncodable(currentUserId),
            "content": AnyEncodable(comment)
        ]
        
        do {
            try await client.from("comments").insert(data).execute()
        } catch {
            LOG.error("Error creating comment: \(error.localizedDescription)")
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func fetchComments(for postId: UUID) async throws -> [Comment] {
        do {
            let comments: [Comment] = try await rpc.call(
                "fetch_comments_for_post",
                params: FetchCommentsParams(p_post_id: postId.uuidString)
            )
            
            return comments
        } catch {
            LOG.error("Error fetching comments: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchReplies(for commentId: UUID) async throws -> [Comment] {
        do {
            let replies: [Comment] = try await rpc.call(
                "fetch_replies_for_comment",
                params: FetchRepliesParams(p_comment_id: commentId.uuidString)
            )
            
            return replies
        } catch {
            LOG.error("Error fetching replies: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - Supporting Types

private struct FetchCommentsParams: Encodable {
    let p_post_id: String
}

private struct FetchRepliesParams: Encodable {
    let p_comment_id: String
}
