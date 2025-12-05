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

    func get(for userID: UUID) -> UserProfile? {
        guard userID == cachedUserID else { return nil }
        return cachedProfile
    }

    func store(_ profile: UserProfile, for userID: UUID) {
        cachedUserID = userID
        cachedProfile = profile
    }

    func clear() {
        cachedProfile = nil
        cachedUserID = nil
    }
}

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

    func fetchUserProfile(for userId: UUID) async throws -> [UserProfile] {
        LOG.debug("Fetching user with following tag")
        
        do {
            let response = try await client
                .rpc("fetch_user_profile", params: [
                    "p_user_id": userId.uuidString
                ])
                .single()
                .execute()
            
            let data = response.data
            
            let decoder = makeUserProfileDecoder()
            let profile = try decoder.decode(UserProfile.self, from: data)
            
            return [profile]
        } catch {
            LOG.error("Error loading profile via RPC: \(error.localizedDescription)")
            throw mapToAppError(error)
        }
    }
    
    func fetchMyUserProfile(refresh: Bool = false) async throws -> [UserProfile] {
        guard let userID = client.auth.currentUser?.id else {
            LOG.notice("No authenticated user found")
            return []
        }

        if !refresh {
            if let cached = await profileCache.get(for: userID) {
                LOG.debug("Returning cached profile for current user")
                return [cached]
            }
        }

        let profile = try await fetchUserProfile(for: userID)
        
        if let profile = profile.first {
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
        
        if let updatedProfile = try await fetchUserProfile(for: userID).first {
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
            "date_of_birth": AnyEncodable(ISO8601DateFormatter().string(from: userProfile.date_of_birth)),
            "phone_number": AnyEncodable(userProfile.phone_number),
            "location": AnyEncodable(userProfile.location),
            "latitude": AnyEncodable(userProfile.latitude),
            "longitude": AnyEncodable(userProfile.longitude)
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
        if let currentProfile = try await fetchMyUserProfile().first,
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
    
    func createPost(content: String, gym_id: UUID? = nil) async throws {
        guard let userID = client.auth.currentUser?.id else {
            LOG.notice("No authenticated user found")
            return
        }

        let data: [String: AnyEncodable] = [
            "id": AnyEncodable(UUID()),
            "user_id": AnyEncodable(userID),
            "content": AnyEncodable(content),
            "created_at": AnyEncodable(Date()),
            "updated_at": AnyEncodable(Date()),
            "gym_id": AnyEncodable(gym_id)
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
            
            try await client
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
        do {
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
        } catch {
            LOG.error("Error fetching user posts: \(error.localizedDescription)")
            throw mapToAppError(error)
        }
    }

    func fetchMyPosts() async throws -> [Post] {
        guard let userId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return []
        }
        
        return try await fetchPosts(for: userId, viewing: userId)
    }
    
    func fetchMentions(for userId: UUID) async throws -> [Post] {
        LOG.debug("fetching user mentions")
        
        do {
            let posts: [Post] = try await client
                .rpc("fetch_user_mentions", params: ["p_user_id": userId])
                .execute()
                .value
            
            return posts
        } catch {
            LOG.error("Error fetching posts: \(error.localizedDescription)")
            throw mapToAppError(error)
        }
    }
    
    func fetchMyMentions() async throws -> [Post] {
        guard let userId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return []
        }
        
        return try await fetchMentions(for: userId)
    }
    
    func fetchNearbyPosts() async throws -> [Post] {
        guard let userId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return []
        }
        
        // 10 miles to meters
        let radiusMeters = 10.0 * 1609.34
        
        LOG.debug("Fetching nearby posts")
        
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
                .value as [Post]
            
            return posts
        } catch {
            throw mapToAppError(error)
        }
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
    
    func fetchFollowingPosts() async throws -> [Post] {
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
                .value as [Post]
            
            LOG.debug("Fetched \(posts.count) posts")

            return posts
            
        } catch {
            LOG.error("Error fetching following posts \(error.localizedDescription)")
            throw mapToAppError(error)
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
    
    func fetchGymMemberships(for userId: UUID, lat: Double? = nil, lon: Double? = nil) async throws -> [Gym] {
        do {
            let gyms = try await client
                .rpc(
                    "fetch_gyms_for_user",
                    params: FetchGymMembershipsParams(p_user_id: userId, user_lat: lat, user_lon: lon)
                )
                .execute()
                .value as [Gym]
            
            return gyms
            
        } catch {
            // TODO: https://github.com/natedoesthings/gympeople/issues/52
            LOG.error("Failed to find memberships. \(error.localizedDescription)")
            throw mapToAppError(error)
        }
    }
    
    func fetchMyGymMemberships() async throws -> [Gym] {
        guard let currentUser = try await fetchMyUserProfile().first else {
            LOG.error("No authenticated user found")
            return []
        }
        
        return try await fetchGymMemberships(for: currentUser.id, lat: currentUser.latitude, lon: currentUser.longitude)
    }
    
    func fetchNearbyGyms(lat: Double, lon: Double) async throws -> [Gym] {
        LOG.info("Fetching nearby gyms")
        
        do {
            let gyms: [Gym] = try await client
                .rpc("fetch_gyms_by_distance", params: [
                    "user_lat": lat,
                    "user_lon": lon,
                    "radius_km": 30,
                    "max_results": 20
                ])
                .execute()
                .value
            
            LOG.info("Fetched \(gyms.count) gyms.")
            return gyms
        
        } catch {
            LOG.error("Error fetching nearby gyms: \(error.localizedDescription)")
            throw mapToAppError(error)
        }
    }
    
    func fetchMyNearbyGyms() async throws -> [Gym] {
        guard let currentUser = try await fetchMyUserProfile().first else {
            LOG.error("No authenticated user found")
            return []
        }
        
        return try await fetchNearbyGyms(lat: currentUser.latitude, lon: currentUser.longitude)
        
    }

    func likePost(for postId: UUID) async {
        guard let currentUserId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return
        }
        
        do {
            try await client
                .from("post_likes")
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
                .from("post_likes")
                .delete()
                .eq("user_id", value: currentUserId.uuidString)
                .eq("post_id", value: postId.uuidString)
                .execute()
            
            LOG.info("Unliked post with id: \(postId)")
            
        } catch {
            LOG.error("Failed to unlike.")
        }
    }
    
    func fetchGymPosts(for gymId: UUID) async throws -> [Post] {
        do {
            let posts: [Post] = try await client
                .rpc("fetch_posts_for_gym", params: ["p_gym_id": gymId.uuidString])
                .execute()
                .value
            
            return posts
        } catch {
            LOG.error("Error fetching gym posts: \(error.localizedDescription)")
            throw mapToAppError(error)
        }
    }
    
    func fetchGymMembers(for gymId: UUID) async throws -> [UserProfile] {
        do {
            let response = try await client
                .rpc("fetch_user_profiles_for_gym", params: ["p_gym_id": gymId])
                .execute()
            
            let decoder = makeUserProfileDecoder()
            return try decoder.decode([UserProfile].self, from: response.data)
        } catch {
            LOG.error("Error fetching gym members: \(error.localizedDescription)")
            throw mapToAppError(error)
        }
    }
    
    func createComment(for postId: UUID, with comment: String, parent parent_id: UUID? = nil) async throws {
        guard let currentUserId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return
        }
        
        do {
            let data: [String: AnyEncodable] = [
                "post_id": AnyEncodable(postId),
                "parent_comment_id": AnyEncodable(parent_id),
                "user_id": AnyEncodable(currentUserId),
                "content": AnyEncodable(comment)
            ]
            
            try await client.from("comments").insert(data).execute()
            
        } catch {
            LOG.error("Error creating post: \(error.localizedDescription)")
            throw mapToAppError(error)
        }
    }
    
    func fetchComments(for postId: UUID) async throws -> [Comment] {
        do {
            let comments: [Comment] = try await client
                .rpc("fetch_comments_for_post", params: [
                    "p_post_id": postId.uuidString
                ])
                .execute()
                .value
            
            return comments
        } catch {
            LOG.error("Error fetching comments \(error.localizedDescription)")
            throw mapToAppError(error)
        }
    }
    
    func fetchReplies(for commentId: UUID) async throws -> [Comment] {
        do {
            let replies: [Comment] = try await client
                .rpc("fetch_replies_for_comment", params: [
                    "p_comment_id": commentId.uuidString
                ])
                .execute()
                .value
            
            return replies
            
        } catch {
            LOG.error("Error fetching replies \(error.localizedDescription)")
            throw mapToAppError(error)
        }
    }
    
    func likeComment(for commentId: UUID) async {
        guard let currentUserId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return
        }
        
        do {
            try await client
                .from("comment_likes")
                .insert(["user_id": AnyEncodable(currentUserId), "comment_id": AnyEncodable(commentId)])
                .execute()
            
            LOG.info("Liked comment with id: \(commentId)")
            
        } catch {
            LOG.error("Failed to like. \(error.localizedDescription)")
        }
    }
    
    func unlikeComment(for commentId: UUID) async {
        guard let currentUserId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return
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
            LOG.error("Failed to unlike. \(error.localizedDescription)")
        }
    }
    
    // MARK: Helpers
    
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
            // Supabase Swift uses PostgrestError / URLError / DecodingError, adjust as needed
            if let pg = error as? PostgrestError {
                switch pg.code {
                case "23505": return .conflict                          // unique violation
                case "23503": return .validationFailed(reason: "Missing related item")
                case "23514": return .validationFailed(reason: "Input violates constraint")
                case "42501": return .unauthorized
                default:       return .unexpected
                }
            } else if let urlErr = error as? URLError {
                switch urlErr.code {
                case .notConnectedToInternet, .timedOut: return .networkUnavailable
                default: return .unexpected
                }
            } else if let httpErr = error as? HTTPError {
                switch httpErr.response.statusCode {
                case 401, 403: return .unauthorized
                case 404: return .notFound
                case 500...599: return .serverError
                default: return .unexpected
                }
            } else if error is DecodingError {
                return .unexpected
            }

            return .unexpected
        }
}

nonisolated
struct SyncGymMembershipsParams: Encodable, Sendable {
    let p_gym_ids: [UUID]
    let p_user_id: UUID
}

nonisolated
struct FetchGymMembershipsParams: Encodable, Sendable {
    let p_user_id: UUID
    let user_lat: Double?
    let user_lon: Double?

    enum CodingKeys: String, CodingKey { case p_user_id, user_lat, user_lon }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(p_user_id, forKey: .p_user_id)
        if let lat = user_lat { try c.encode(lat, forKey: .user_lat) } else { try c.encodeNil(forKey: .user_lat) }
        if let lon = user_lon { try c.encode(lon, forKey: .user_lon) } else { try c.encodeNil(forKey: .user_lon) }
    }
}
