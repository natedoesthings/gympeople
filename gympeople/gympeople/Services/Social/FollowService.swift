//
//  FollowService.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import Foundation
import Supabase

protocol FollowServiceProtocol {
    func followUser(_ userId: UUID) async throws
    func unfollowUser(_ userId: UUID) async throws
    func fetchFollowing(for userId: UUID) async throws -> [UserProfile]
    func fetchFollowers(for userId: UUID) async throws -> [UserProfile]
    func fetchMyFollowing() async throws -> [UserProfile]
    func fetchMyFollowers() async throws -> [UserProfile]
    func fetchNearbyUsers(for userId: UUID) async throws -> [UserProfile]
    func fetchMyNearbyUsers() async throws -> [UserProfile]
}

class FollowService: FollowServiceProtocol {
    private let client: SupabaseClient
    private let rpc: RPCRepository
    private let decoder = DateDecoderHelper.makeDecoder()
    
    init(client: SupabaseClient) {
        self.client = client
        self.rpc = RPCRepository(client: client)
    }
    
    func followUser(_ userId: UUID) async throws {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }
        
        LOG.debug("Following user: \(userId)")
        
        let relation: [String: AnyEncodable] = [
            "follower_id": AnyEncodable(currentUserId.uuidString),
            "followee_id": AnyEncodable(userId.uuidString)
        ]

        do {
            try await client
                .from("user_relations")
                .insert(relation)
                .execute()
        } catch {
            LOG.error("Failed to follow user: \(error)")
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func unfollowUser(_ userId: UUID) async throws {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }

        LOG.debug("Unfollowing user: \(userId)")
        
        do {
            try await client
                .from("user_relations")
                .delete()
                .eq("follower_id", value: currentUserId.uuidString)
                .eq("followee_id", value: userId.uuidString)
                .execute()
        } catch {
            LOG.error("Failed to unfollow user: \(error)")
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func fetchFollowing(for userId: UUID) async throws -> [UserProfile] {
        LOG.debug("Fetching following for user: \(userId)")
        
        do {
            let response = try await client
                .rpc("fetch_user_following", params: FetchUserRelationsParams(p_user_id: userId.uuidString))
                .execute()
            
            return try decoder.decode([UserProfile].self, from: response.data)
        } catch {
            LOG.error("Error fetching following: \(error.localizedDescription)")
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func fetchFollowers(for userId: UUID) async throws -> [UserProfile] {
        LOG.debug("Fetching followers for user: \(userId)")
        
        do {
            let response = try await client
                .rpc("fetch_user_followers", params: FetchUserRelationsParams(p_user_id: userId.uuidString))
                .execute()
            
            return try decoder.decode([UserProfile].self, from: response.data)
        } catch {
            LOG.error("Error fetching followers: \(error.localizedDescription)")
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func fetchMyFollowing() async throws -> [UserProfile] {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }
        
        return try await fetchFollowing(for: currentUserId)
    }
    
    func fetchMyFollowers() async throws -> [UserProfile] {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }
        
        return try await fetchFollowers(for: currentUserId)
    }
    
    func fetchNearbyUsers(for userId: UUID) async throws -> [UserProfile] {
        LOG.debug("Fetching nearby users for user: \(userId)")
        
        do {
            let response = try await client
                .rpc("fetch_nearby_users", params: FetchUserRelationsParams(p_user_id: userId.uuidString))
                .execute()
            
            let profiles = try decoder.decode([UserProfile].self, from: response.data)
            
            LOG.debug("Found \(profiles.count) nearby users")
            return profiles
        } catch {
            LOG.error("Error fetching nearby users: \(error.localizedDescription)")
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func fetchMyNearbyUsers() async throws -> [UserProfile] {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }
        
        return try await fetchNearbyUsers(for: currentUserId)
    }
}

// MARK: - Supporting Types
nonisolated
private struct FetchUserRelationsParams: Encodable {
    let p_user_id: String
}
