//
//  SupabaseManager.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/11/25.
//
//  LEGACY COMPATIBILITY LAYER
//  This class now delegates to the new modular services in Services/
//  Consider migrating to ServiceContainer.shared directly in new code
//

import Foundation
import Supabase
import CoreLocation
import PhotosUI

class SupabaseManager {
    static let shared = SupabaseManager()
    let client: SupabaseClient
    
    // New modular services
    private let services = ServiceContainer.shared

    private init() {
        client = ServiceContainer.shared.client
    }
}

// MARK: - Profile Methods (Delegate to ProfileService)

extension SupabaseManager {
    func saveUserProfile(
        firstName: String,
        lastName: String,
        userName: String,
        email: String,
        dob: Date,
        phone: String,
        latitude: Double,
        longitude: Double,
        location: String
    ) async throws {
        try await services.profile.saveUserProfile(
            firstName: firstName,
            lastName: lastName,
            userName: userName,
            email: email,
            dob: dob,
            phone: phone,
            latitude: latitude,
            longitude: longitude,
            location: location
        )
    }

    func fetchUserProfile(for userId: UUID) async throws -> [UserProfile] {
        let profile = try await services.profile.fetchUserProfile(for: userId)
        return [profile]
    }
    
    func fetchMyUserProfile(refresh: Bool = false) async throws -> [UserProfile] {
        let profile = try await services.profile.fetchMyUserProfile(refresh: refresh)
        return [profile]
    }

    func searchUserProfiles(matching query: String, limit: Int = 20) async throws -> [UserProfile] {
        try await services.profile.searchUserProfiles(matching: query, limit: limit)
    }
    
    func updateUserProfile(fields: [String: AnyEncodable]) async throws {
        try await services.profile.updateUserProfile(fields: fields)
    }
    
    func updateUserProfile(userProfile: UserProfile) async throws {
        try await services.profile.updateUserProfile(userProfile: userProfile)
    }
    
    func uploadProfilePicture(_ image: UIImage) async throws {
        try await services.storage.uploadProfilePicture(image)
    }

    func clearUserProfileCache() async {
        await services.profile.clearCache()
    }
    
    func checkUserName(userName: String) async -> Bool {
        await services.profile.checkUserName(userName: userName)
    }
}

// MARK: - Post Methods (Delegate to PostService)

extension SupabaseManager {
    func createPost(content: String, gym_id: UUID? = nil) async throws {
        try await services.post.createPost(content: content, gymId: gym_id)
    }
    
    func fetchPosts(for authorId: UUID, viewing viewerId: UUID? = nil) async throws -> [Post] {
        try await services.post.fetchPosts(for: authorId, viewing: viewerId)
    }

    func fetchMyPosts() async throws -> [Post] {
        try await services.post.fetchMyPosts()
    }
    
    func fetchMentions(for userId: UUID) async throws -> [Post] {
        try await services.post.fetchMentions(for: userId)
    }
    
    func fetchMyMentions() async throws -> [Post] {
        try await services.post.fetchMyMentions()
    }
    
    func fetchNearbyPosts() async throws -> [Post] {
        try await services.post.fetchNearbyPosts()
    }
    
    func fetchFollowingPosts() async throws -> [Post] {
        try await services.post.fetchFollowingPosts()
    }
    
    func fetchGymPosts(for gymId: UUID) async throws -> [Post] {
        try await services.post.fetchGymPosts(for: gymId)
    }
    
    func updatePost(post_id: UUID, content: String) async throws {
        try await services.post.updatePost(postId: post_id, content: content)
    }
    
    func deletePost(post_id: UUID) async {
        try? await services.post.deletePost(postId: post_id)
    }
}

// MARK: - Follow Methods (Delegate to FollowService)

extension SupabaseManager {
    func removeFollowee(userId: UUID) async {
        try? await services.follow.unfollowUser(userId)
    }

    func addFollowee(userId: UUID) async {
        try? await services.follow.followUser(userId)
    }
    
    func fetchFollowing(for userId: UUID) async throws -> [UserProfile] {
        try await services.follow.fetchFollowing(for: userId)
    }
    
    func fetchFollowers(for userId: UUID) async throws -> [UserProfile] {
        try await services.follow.fetchFollowers(for: userId)
    }
    
    func fetchMyFollowing() async throws -> [UserProfile] {
        try await services.follow.fetchMyFollowing()
    }
    
    func fetchMyFollowers() async throws -> [UserProfile] {
        try await services.follow.fetchMyFollowers()
    }
    
    func fetchNearbyUsers(for userId: UUID) async throws -> [UserProfile] {
        try await services.follow.fetchNearbyUsers(for: userId)
    }
    
    func fetchMyNearbyUsers() async throws -> [UserProfile] {
        try await services.follow.fetchMyNearbyUsers()
    }
}

// MARK: - Gym Methods (Delegate to GymService & GymMembershipService)

extension SupabaseManager {
    func insertGyms(_ gyms: [[String: AnyEncodable]]) async -> [Gym]? {
        try? await services.gym.insertGyms(gyms)
    }
    
    func insertGyms(_ gyms: [Gym]) async -> [Gym]? {
        try? await services.gym.insertGyms(gyms)
    }
    
    func insertGymMemberships(_ insertedGyms: [Gym]) async {
        try? await services.gymMembership.insertGymMemberships(insertedGyms)
    }
    
    func syncGymMemberships(gyms: [Gym]) async {
        try? await services.gymMembership.syncGymMemberships(gyms: gyms)
    }
    
    func fetchGymMemberships(for userId: UUID, lat: Double? = nil, lon: Double? = nil) async throws -> [Gym] {
        try await services.gymMembership.fetchGymMemberships(for: userId, lat: lat, lon: lon)
    }
    
    func updateMembershipVerification(gymId: UUID, documentUrl: String) async throws {
        try await services.gymMembership.updateMembershipVerification(gymId: gymId, documentUrl: documentUrl)
    }
    
    func fetchMyGymMemberships() async throws -> [Gym] {
        guard let currentUser = try await fetchMyUserProfile().first else {
            throw AppError.unauthorized
        }
        
        return try await services.gymMembership.fetchGymMemberships(
            for: currentUser.id,
            lat: currentUser.latitude,
            lon: currentUser.longitude
        )
    }
    
    func fetchNearbyGyms(lat: Double, lon: Double) async throws -> [Gym] {
        try await services.gym.fetchNearbyGyms(lat: lat, lon: lon)
    }
    
    func fetchMyNearbyGyms() async throws -> [Gym] {
        guard let currentUser = try await fetchMyUserProfile().first else {
            throw AppError.unauthorized
        }
        
        return try await services.gym.fetchNearbyGyms(lat: currentUser.latitude, lon: currentUser.longitude)
    }
    
    func fetchGymMembers(for gymId: UUID) async throws -> [UserProfile] {
        try await services.gym.fetchGymMembers(for: gymId)
    }
}

// MARK: - Like Methods (Delegate to LikeService)

extension SupabaseManager {
    func likePost(for postId: UUID) async {
        try? await services.like.likePost(for: postId)
    }
    
    func unlikePost(for postId: UUID) async {
        try? await services.like.unlikePost(for: postId)
    }
    
    func likeComment(for commentId: UUID) async {
        try? await services.like.likeComment(for: commentId)
    }
    
    func unlikeComment(for commentId: UUID) async {
        try? await services.like.unlikeComment(for: commentId)
    }
}

// MARK: - Comment Methods (Delegate to CommentService)

extension SupabaseManager {
    func createComment(for postId: UUID, with comment: String, parent parent_id: UUID? = nil) async throws {
        try await services.comment.createComment(for: postId, with: comment, parentId: parent_id)
    }
    
    func fetchComments(for postId: UUID) async throws -> [Comment] {
        try await services.comment.fetchComments(for: postId)
    }
    
    func fetchReplies(for commentId: UUID) async throws -> [Comment] {
        try await services.comment.fetchReplies(for: commentId)
    }
}

// MARK: - Legacy Helper Methods (Kept for backward compatibility)

extension SupabaseManager {
    // These helper methods are kept but no longer used internally
    // They're here in case any external code references them
    
    private func makeUserProfileDecoder() -> JSONDecoder {
        DateDecoderHelper.makeDecoder()
    }

    private func storagePath(fromPublicURL urlString: String, bucket: String) -> String? {
        guard let url = URL(string: urlString) else { return nil }
        let components = url.pathComponents
        guard let bucketIndex = components.firstIndex(of: bucket),
              bucketIndex + 1 < components.count else { return nil }
        let pathComponents = components[(bucketIndex + 1)...]
        let path = pathComponents.joined(separator: "/")
        return path.isEmpty ? nil : path
    }
    
    private func mapToAppError(_ error: Error) -> AppError {
        SupabaseErrorMapper.map(error)
    }
}
