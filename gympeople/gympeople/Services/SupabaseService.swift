//
//  SupabaseManager.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/11/25.
//

import Foundation
import Supabase
import CoreLocation
import PhotosUI

class SupabaseManager {
    static let shared = SupabaseManager()
    let client: SupabaseClient
    private let profileCache = UserProfileCache()


    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Env.supabaseURL)!,
            supabaseKey: Env.supabaseAnonKey
        )
    }
}

actor UserProfileCache {
    private var cachedProfile: UserProfile?
    private var cachedUserID: UUID?
    private var cachedUserPosts: [Post]?
    private var cachedMemberships: [Gym]?

    func get(for userID: UUID) -> UserProfile? {
        guard userID == cachedUserID else { return nil }
        return cachedProfile
    }

    func store(_ profile: UserProfile, for userID: UUID) {
        cachedUserID = userID
        cachedProfile = profile
    }
    
    func storePosts(_ posts: [Post]) {
        cachedUserPosts = posts
    }
    
    func storeMemberships(_ memberships: [Gym]) {
        cachedMemberships = memberships
    }

    func clear() {
        cachedProfile = nil
        cachedUserID = nil
        cachedUserPosts = nil
        cachedMemberships = nil
    }
}

extension SupabaseManager {
    private func makeUserProfileDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")

        // Supabase/PostgREST returns timestamps with fractional seconds (e.g. 2024-12-13T02:19:28.123456+00:00)
        let isoFormatterWithFractional = ISO8601DateFormatter()
        isoFormatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try ISO8601 with fractional seconds first (Supabase default)
            if let date = isoFormatterWithFractional.date(from: dateString) {
                return date
            }
            // Try standard ISO8601
            if let date = ISO8601DateFormatter().date(from: dateString) {
                return date
            }
            // Try yyyy-MM-dd'T'HH:mm:ssZZZZZ
            if let date = formatter.date(from: dateString) {
                return date
            }
            // Try yyyy-MM-dd (date-only)
            let shortFormatter = DateFormatter()
            shortFormatter.dateFormat = "yyyy-MM-dd"
            if let date = shortFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unrecognized date format: \(dateString)"
            )
        }

        return decoder
    }

    func saveUserProfile(
        firstName: String,
        lastName: String,
        userName: String,
        email: String,
        dob: Date,
        phone: String,
        latitude: Double,
        longitude: Double,
        location: String,
        gyms: [String]
    ) async throws {
        let data: [String: AnyEncodable] = [
            "id": AnyEncodable(client.auth.currentUser?.id),
            "first_name": AnyEncodable(firstName),
            "last_name": AnyEncodable(lastName),
            "user_name": AnyEncodable(userName),
            "biography": AnyEncodable(""),
            "email": AnyEncodable(email),
            "date_of_birth": AnyEncodable(ISO8601DateFormatter().string(from: dob)),
            "phone_number": AnyEncodable(phone),
            "latitude": AnyEncodable(latitude),
            "longitude": AnyEncodable(longitude),
            "location": AnyEncodable(location.isEmpty ? nil : location),
            "is_private": AnyEncodable(false) // public by default
        ]
        try await client.from("user_profiles").insert(data).execute()
    }

    func fetchUserProfile(for userID: UUID) async throws -> UserProfile? {
        LOG.debug("Calling Fetch Request for user profile")
        
        let response = try await client
            .from("user_profiles")
            .select()
            .eq("id", value: userID)
            .single()
            .execute()
        
        let data = response.data
        
        let decoder = makeUserProfileDecoder()
        let profile = try decoder.decode(UserProfile.self, from: data)
        return profile
    }
    
    func fetchMyUserProfile(refresh: Bool = false) async throws -> UserProfile? {
        guard let userID = client.auth.currentUser?.id else {
            LOG.notice("No authenticated user found")
            return nil
        }

        if !refresh {
            if let cached = await profileCache.get(for: userID) {
                LOG.debug("Returning cached profile for current user")
                return cached
            }
        }

        let profile = try await fetchUserProfile(for: userID)
        if let profile {
            await profileCache.store(profile, for: userID)
        }

        return profile
    }

    func searchUserProfiles(matching query: String, limit: Int = 20) async throws -> [UserProfile] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }

        let response = try await client
            .from("user_profiles")
            .select()
            .or("user_name.ilike.%\(trimmedQuery)%,full_name.ilike.%\(trimmedQuery)%")
            .order("user_name", ascending: true)
            .execute()

        let decoder = makeUserProfileDecoder()
        return try decoder.decode([UserProfile].self, from: response.data)
    }
    
    // Update individual fields
    func updateUserProfile(fields: [String: AnyEncodable]) async throws {
        guard let userID = client.auth.currentUser?.id else {
            LOG.notice("No authenticated user found")
            return
        }
        
        LOG.debug("updating: \(fields.keys)")
        try await client
            .from("user_profiles")
            .update(fields)
            .eq("id", value: userID)
            .execute()
        
        try await Task.sleep(nanoseconds: 250_000_000)

        if let updatedProfile = try await fetchUserProfile(for: userID) {
            await profileCache.store(updatedProfile, for: userID)
        }
    }
    
    // Update whole profile
    func updateUserProfile(userProfile: UserProfile) async throws {
        guard let userID = client.auth.currentUser?.id else {
            LOG.notice("No authenticated user found")
            return
        }
        
        let fields: [String: AnyEncodable] = [
            "first_name": AnyEncodable(userProfile.first_name),
            "last_name": AnyEncodable(userProfile.last_name),
            "user_name": AnyEncodable(userProfile.user_name),
            "biography": AnyEncodable(userProfile.biography),
            "email": AnyEncodable(userProfile.email),
            "date_of_birth": AnyEncodable(ISO8601DateFormatter().string(from: userProfile.date_of_birth)),
            "phone_number": AnyEncodable(userProfile.phone_number),
            "location": AnyEncodable(userProfile.location),
            "latitude": AnyEncodable(userProfile.latitude),
            "longitude": AnyEncodable(userProfile.longitude),
        ]

        try await client
            .from("user_profiles")
            .update(fields)
            .eq("id", value: userID)
            .execute()

        await profileCache.store(userProfile, for: userID)
    }
    
    func uploadProfilePicture(_ image: UIImage) async throws {
        LOG.info("Updating Profile Picture...")
        
        guard let userID = client.auth.currentUser?.id else {
            LOG.notice("No authenticated user found")
            return
        }

        let bucket = "profile_pictures"

        // Try to clean up any existing profile picture before uploading a new one.
        if let currentProfile = try? await fetchMyUserProfile(),
           let currentURLString = currentProfile.pfp_url,
           let path = storagePath(fromPublicURL: currentURLString, bucket: bucket) {
            do {
                try await client.storage
                    .from(bucket)
                    .remove(paths: [path])
                LOG.debug("Removed old profile picture at path: \(path)")
            } catch {
                LOG.error("Failed to remove old profile picture: \(error)")
            }
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG."])
        }

        let timestamp = Int(Date().timeIntervalSince1970)
        let fileName = "\(userID.uuidString)_\(timestamp).jpg"

        // 1. Upload to storage
        do {
            try await client.storage
                .from(bucket)
                .upload(fileName, data: imageData, options: FileOptions(contentType: "image/jpeg", upsert: true))
            
            do {
                // 2. Get public URL
                let publicURL = try client.storage
                    .from(bucket)
                    .getPublicURL(path: fileName)
                
                do {
                    // Save the profile picture
                    try await updateUserProfile(fields: ["pfp_url": AnyEncodable(publicURL.absoluteString)])
                } catch {
                    LOG.error("Error updating profile with url \(error)")
                }
                
            } catch {
                LOG.error("Error grabbing public url \(error)")
            }
            
        } catch {
            LOG.error("Error uploading to storage \(error)")
        }
        
        LOG.info("Profile Picture Updated!")
    }

    func clearUserProfileCache() async {
        await profileCache.clear()
    }
    
    func createPost(content: String) async throws {
        guard let userID = client.auth.currentUser?.id else {
            LOG.notice("No authenticated user found")
            return
        }

        let data: [String: AnyEncodable] = [
            "id": AnyEncodable(UUID()),
            "user_id": AnyEncodable(userID),
            "content": AnyEncodable(content),
            "created_at": AnyEncodable(Date()),
            "updated_at": AnyEncodable(Date())
        ]

        try await client.from("posts").insert(data).execute()
    }
    
    func checkUserName(userName: String) async -> Bool {
        do {
            if let userID = client.auth.currentUser?.id {
                if let cached = await profileCache.get(for: userID) {
                    if userName == cached.user_name {
                        return true
                    }
                }
            }
            
            let _ = try await client
                .from("user_profiles")
                .select("id")
                .eq("user_name", value: userName)
                .single()
                .execute()
            
            // Successfully finds a username
            return false
        } catch {
            print("Error checking username:", error)
            return true
        }
    }
    
    func fetchPosts(for authorId: UUID, viewing viewerId: UUID? = nil) async throws -> [Post] {
        if let viewerId = viewerId {
            let posts = try await client
                .rpc("fetch_user_posts", params: [
                    "viewer_id": viewerId.uuidString,
                    "author_id": authorId.uuidString
                ])
                .execute()
                .value as [Post]
            
            return posts
            
        } else {
            guard let currentUserId = client.auth.currentUser?.id else {
                LOG.error("No authenticated user found")
                return []
            }
            
            let posts = try await client
                .rpc("fetch_user_posts", params: [
                    "viewer_id": currentUserId.uuidString,
                    "author_id": authorId.uuidString
                ])
                .execute()
                .value as [Post]
            
            return posts
            
        }
    }

    func fetchMyPosts() async throws -> [Post] {
        guard let userId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return []
        }
        
        return try await fetchPosts(for: userId, viewing: userId)
    }
    
    
    func fetchNearbyPosts() async throws -> [NearbyPost] {
        guard let userId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return []
        }

        // 10 miles to meters
        let radiusMeters = 10.0 * 1609.34

        do {
            let posts = try await client
                .rpc(
                    "fetch_nearby_posts_with_authors",
                    params: [
                        "p_user_id": userId.uuidString,
                        "p_radius_meters": String(radiusMeters)
                    ]
                )
                .execute()
                .value as [NearbyPost]

            return posts
        } catch {
            LOG.error("Error fetching nearby posts: \(error)")
            throw error
        }
    }
    
    func checkIfFollowing(userId: UUID) async throws -> Bool {
        guard let currentUserId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return false
        }
        
        LOG.debug("Checking if following \(userId)")
        
        let response = try await client
            .rpc("is_following",
                 params: [
                    "follower": currentUserId.uuidString,
                    "followee": userId.uuidString
            ])
            .execute()
            .value as Bool
        
        LOG.debug("Is following: \(response)")
        
        return response
    }
    
    func removeFollowee(userId: UUID) async {
        guard let currentUserId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return
        }

        LOG.debug("unfollowing \(userId)")
        
        do {
            try await client
                .from("user_relations")
                .delete()
                .eq("follower_id", value: currentUserId.uuidString)
                .eq("followee_id", value: userId.uuidString)
                .execute()

        } catch let error {
            LOG.error("Failed to unfollow user: \(error)")
        }
    }

    
    func addFollowee(userId: UUID) async {
        guard let currentUserId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return
        }
        
        LOG.debug("following \(userId)")
        
        let relation: [String: AnyEncodable] = [
            "follower_id": AnyEncodable(currentUserId.uuidString),
            "followee_id": AnyEncodable(userId.uuidString)
        ]

        do {
            try await client
                .from("user_relations")
                .insert(relation)
                .execute()
            
        } catch let error {
            LOG.error("Failed to follow user: \(error)")
        }
    }
    
    func fetchFollowingPosts() async -> [FollowingPost] {
        guard let currentUserId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return []
        }

        LOG.debug("Fetching following posts")
        
        do {
            let posts = try await client
                .rpc("fetch_following_posts_with_authors", params: [
                    "user_id_param": currentUserId.uuidString
                ])
                .execute()
                .value as [FollowingPost]
            
            LOG.debug("Fetched \(posts.count) posts")

            return posts
            
        } catch {
            LOG.error("Error fetching following posts \(error.localizedDescription)")
            return []
        }
        
    }
    
    func updatePost(post_id: UUID, content: String) async throws {
        LOG.debug("updating post \(post_id)")
        
        try await client
            .from("posts")
            .update(["content": AnyEncodable(content)])
            .eq("id", value: post_id.uuidString)
            .execute()
    
    }
    
    func deletePost(post_id: UUID) async {
        LOG.debug("deleting post \(post_id)")
        
        do {
            try await client
                .from("posts")
                .delete()
                .eq("id", value: post_id.uuidString)
                .execute()

        } catch let error {
            LOG.error("Failed to delete: \(error)")
        }
    }
    
    func insertGyms(_ gyms: [[String: AnyEncodable]]) async -> [Gym]? {
        if gyms.isEmpty { return nil }
        
        do {
            let gyms = try await client
                .from("gyms")
                .upsert(gyms, onConflict: "address")
                .select()
                .execute()
                .value as [Gym]
            
            LOG.notice("Inserted \(gyms.count) gyms")
            return gyms
            
        } catch {
            LOG.error("Failed to insert gyms: \(error)")
            return nil
        }
    }
    
    func insertGyms(_ gyms: [Gym]) async -> [Gym]? {
        if gyms.isEmpty { return nil }
        
        do {
            let gyms = try await client
                .from("gyms")
                .upsert(gyms, onConflict: "address")
                .select()
                .execute()
                .value as [Gym]
            
            LOG.notice("Inserted \(gyms.count) gyms")
            return gyms
            
        } catch {
            LOG.error("Failed to insert gyms: \(error)")
            return nil
        }
    }
    
    func insertGymMemberships(_ insertedGyms: [Gym]) async {
        guard let currentUserId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return
        }
        
        var membershipPayloads: [[String: AnyEncodable]] = []

        for gym in insertedGyms {
            membershipPayloads.append([
                "user_id": AnyEncodable(currentUserId),
                "gym_id": AnyEncodable(gym.id.uuidString)
            ])
        }
        
        do {
            try await client
                .from("gym_memberships")
                .insert(membershipPayloads)
                .execute()
            
            LOG.notice("Inserted \(insertedGyms.count) memberships")
        } catch {
            LOG.error("Failed to insert memberships.")
        }
        
    }
    
    func syncGymMemberships(gyms: [Gym]) async {
        guard let currentUserId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return
        }
        
        do {
            _ = try await client
                .rpc(
                    "sync_gym_memberships",
                    params: SyncGymMembershipsParams(p_gym_ids: gyms.map { $0.id }, p_user_id: currentUserId)
                )
                .execute()
        } catch {
            LOG.error("Failed syncing memberships. \(error.localizedDescription)")
        }
    }
    
    func fetchGymMemberships(for userId: UUID) async -> [Gym] {
        do {
            let gyms = try await client
                .rpc(
                    "fetch_gyms_for_user",
                    params: ["p_user_id": userId]
                )
                .execute()
                .value as [Gym]
            
            return gyms
            
        } catch {
            LOG.error("Failed to find memberships.")
            return []
        }
    }
    
    func fetchMyGymMemberships() async -> [Gym] {
        guard let currentUserId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return []
        }
        
        do {
            let gyms = try await client
                .rpc(
                    "fetch_gyms_for_user",
                    params: ["p_user_id": currentUserId]
                )
                .execute()
                .value as [Gym]
            
            return gyms
            
        } catch {
            LOG.error("Failed to find memberships.")
            return []
        }
    }
    
    func likePost(for postId: UUID) async {
        guard let currentUserId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return
        }
        
        do {
            try await client
                .from("likes")
                .insert(["user_id": AnyEncodable(currentUserId), "post_id": AnyEncodable(postId)])
                .execute()
            
            LOG.info("Liked post with id: \(postId)")
            
        } catch {
            LOG.error("Failed to like.")
        }
    }
    
    func unlikePost(for postId: UUID) async {
        guard let currentUserId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return
        }
        
        do {
            try await client
                .from("likes")
                .delete()
                .eq("user_id", value: currentUserId.uuidString)
                .eq("post_id", value: postId.uuidString)
                .execute()
            
            LOG.info("Unliked post with id: \(postId)")
            
        } catch {
            LOG.error("Failed to unlike.")
        }
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
}

nonisolated
struct SyncGymMembershipsParams: Encodable, Sendable {
    let p_gym_ids: [UUID]
    let p_user_id: UUID
}
