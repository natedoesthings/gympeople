//
//  ServiceContainer.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import Foundation
import Supabase

/// Centralized dependency injection container for all services
class ServiceContainer {
    static let shared = ServiceContainer()
    
    // Core
    let client: SupabaseClient
    
    // Services
    let profile: ProfileService
    let post: PostService
    let comment: CommentService
    let like: LikeService
    let follow: FollowService
    let gym: GymService
    let gymMembership: GymMembershipService
    let storage: StorageService
    
    private init() {
        // Initialize client
        self.client = SupabaseClientProvider.shared.client
        
        // Initialize services
        self.profile = ProfileService(client: client)
        self.post = PostService(client: client)
        self.comment = CommentService(client: client)
        self.like = LikeService(client: client)
        self.follow = FollowService(client: client)
        self.gym = GymService(client: client)
        self.gymMembership = GymMembershipService(client: client)
        self.storage = StorageService(client: client)
    }
}

// MARK: - Convenience Access

extension ServiceContainer {
    /// Access the current authenticated user ID
    var currentUserId: UUID? {
        client.auth.currentUser?.id
    }
    
    /// Check if user is authenticated
    var isAuthenticated: Bool {
        client.auth.currentUser != nil
    }
}
