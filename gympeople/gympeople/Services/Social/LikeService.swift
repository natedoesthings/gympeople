//
//  LikeService.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import Foundation
import Supabase

protocol LikeServiceProtocol {
    func likePost(for postId: UUID) async throws
    func unlikePost(for postId: UUID) async throws
    func likeComment(for commentId: UUID) async throws
    func unlikeComment(for commentId: UUID) async throws
}

class LikeService: LikeServiceProtocol {
    private let client: SupabaseClient
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    // MARK: - Post Likes
    
    func likePost(for postId: UUID) async throws {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }
        
        do {
            try await client
                .from("post_likes")
                .insert(["user_id": AnyEncodable(currentUserId), "post_id": AnyEncodable(postId)])
                .execute()
            
            LOG.info("Liked post with id: \(postId)")
        } catch {
            LOG.error("Failed to like post: \(error.localizedDescription)")
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func unlikePost(for postId: UUID) async throws {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }
        
        do {
            try await client
                .from("post_likes")
                .delete()
                .eq("user_id", value: currentUserId.uuidString)
                .eq("post_id", value: postId.uuidString)
                .execute()
            
            LOG.info("Unliked post with id: \(postId)")
        } catch {
            LOG.error("Failed to unlike post: \(error.localizedDescription)")
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    // MARK: - Comment Likes
    
    func likeComment(for commentId: UUID) async throws {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }
        
        do {
            try await client
                .from("comment_likes")
                .insert(["user_id": AnyEncodable(currentUserId), "comment_id": AnyEncodable(commentId)])
                .execute()
            
            LOG.info("Liked comment with id: \(commentId)")
        } catch {
            LOG.error("Failed to like comment: \(error.localizedDescription)")
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func unlikeComment(for commentId: UUID) async throws {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }
        
        do {
            try await client
                .from("comment_likes")
                .delete()
                .eq("user_id", value: currentUserId.uuidString)
                .eq("comment_id", value: commentId.uuidString)
                .execute()
            
            LOG.info("Unliked comment with id: \(commentId)")
        } catch {
            LOG.error("Failed to unlike comment: \(error.localizedDescription)")
            throw SupabaseErrorMapper.map(error)
        }
    }
}
