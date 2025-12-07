//
//  PostService.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import Foundation
import Supabase

protocol PostServiceProtocol {
    func createPost(content: String, gymId: UUID?) async throws
    func fetchPosts(for authorId: UUID, viewing viewerId: UUID?) async throws -> [Post]
    func fetchMyPosts() async throws -> [Post]
    func fetchMentions(for userId: UUID) async throws -> [Post]
    func fetchMyMentions() async throws -> [Post]
    func fetchNearbyPosts() async throws -> [Post]
    func fetchFollowingPosts() async throws -> [Post]
    func fetchGymPosts(for gymId: UUID) async throws -> [Post]
    func updatePost(postId: UUID, content: String) async throws
    func deletePost(postId: UUID) async throws
}

class PostService: PostServiceProtocol {
    private let client: SupabaseClient
    private let rpc: RPCRepository
    
    init(client: SupabaseClient) {
        self.client = client
        self.rpc = RPCRepository(client: client)
    }
    
    func createPost(content: String, gymId: UUID? = nil) async throws {
        guard let userID = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }

        let data: [String: AnyEncodable] = [
            "id": AnyEncodable(UUID()),
            "user_id": AnyEncodable(userID),
            "content": AnyEncodable(content),
            "created_at": AnyEncodable(Date()),
            "updated_at": AnyEncodable(Date()),
            "gym_id": AnyEncodable(gymId)
        ]

        do {
            try await client.from("posts").insert(data).execute()
        } catch {
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func fetchPosts(for authorId: UUID, viewing viewerId: UUID? = nil) async throws -> [Post] {
        let actualViewerId = viewerId ?? client.auth.currentUser?.id
        
        guard let actualViewerId = actualViewerId else {
            LOG.error("No authenticated user found")
            throw AppError.unauthorized
        }
        
        do {
            let posts: [Post] = try await rpc.call(
                "fetch_user_posts",
                params: FetchUserPostsParams(
                    viewer_id: actualViewerId.uuidString,
                    author_id: authorId.uuidString
                )
            )
            
            return posts
        } catch {
            LOG.error("Error fetching user posts: \(error.localizedDescription)")
            throw error
        }
    }

    func fetchMyPosts() async throws -> [Post] {
        guard let userId = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }
        
        return try await fetchPosts(for: userId, viewing: userId)
    }
    
    func fetchMentions(for userId: UUID) async throws -> [Post] {
        LOG.debug("Fetching user mentions")
        
        do {
            let posts: [Post] = try await rpc.call(
                "fetch_user_mentions",
                params: FetchUserMentionsParams(p_user_id: userId)
            )
            
            return posts
        } catch {
            LOG.error("Error fetching mentions: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchMyMentions() async throws -> [Post] {
        guard let userId = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }
        
        return try await fetchMentions(for: userId)
    }
    
    func fetchNearbyPosts() async throws -> [Post] {
        guard let userId = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }
        
        // 10 miles to meters
        let radiusMeters = 10.0 * 1609.34
        
        LOG.debug("Fetching nearby posts")
        
        do {
            let posts: [Post] = try await rpc.call(
                "fetch_nearby_posts_with_authors",
                params: FetchNearbyPostsParams(
                    p_user_id: userId.uuidString,
                    p_radius_meters: String(radiusMeters)
                )
            )
            
            return posts
        } catch {
            throw error
        }
    }
    
    func fetchFollowingPosts() async throws -> [Post] {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }

        LOG.debug("Fetching following posts")
        
        do {
            let posts: [Post] = try await rpc.call(
                "fetch_following_posts_with_authors",
                params: FetchFollowingPostsParams(user_id_param: currentUserId.uuidString)
            )
            
            LOG.debug("Fetched \(posts.count) posts")
            return posts
        } catch {
            LOG.error("Error fetching following posts: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchGymPosts(for gymId: UUID) async throws -> [Post] {
        do {
            let posts: [Post] = try await rpc.call(
                "fetch_posts_for_gym",
                params: FetchGymPostsParams(p_gym_id: gymId.uuidString)
            )
            
            return posts
        } catch {
            LOG.error("Error fetching gym posts: \(error.localizedDescription)")
            throw error
        }
    }
    
    func updatePost(postId: UUID, content: String) async throws {
        LOG.debug("Updating post \(postId)")
        
        do {
            try await client
                .from("posts")
                .update(["content": AnyEncodable(content)])
                .eq("id", value: postId.uuidString)
                .execute()
        } catch {
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func deletePost(postId: UUID) async throws {
        LOG.debug("Deleting post \(postId)")
        
        do {
            try await client
                .from("posts")
                .delete()
                .eq("id", value: postId.uuidString)
                .execute()
        } catch {
            throw SupabaseErrorMapper.map(error)
        }
    }
}

// MARK: - Supporting Types

private struct FetchUserPostsParams: Encodable {
    let viewer_id: String
    let author_id: String
}

private struct FetchUserMentionsParams: Encodable {
    let p_user_id: UUID
}

private struct FetchNearbyPostsParams: Encodable {
    let p_user_id: String
    let p_radius_meters: String
}

private struct FetchFollowingPostsParams: Encodable {
    let user_id_param: String
}

private struct FetchGymPostsParams: Encodable {
    let p_gym_id: String
}
