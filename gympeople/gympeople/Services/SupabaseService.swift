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
            "gym_memberships": AnyEncodable(gyms)
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
    
    func fetchMyUserProfile() async throws -> UserProfile? {
        guard let userID = client.auth.currentUser?.id else {
            LOG.notice("No authenticated user found")
            return nil
        }

        if let cached = await profileCache.get(for: userID) {
            LOG.debug("Returning cached profile for current user")
            return cached
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
            .ilike("user_name", pattern: "%\(trimmedQuery)%")
            .order("user_name", ascending: true)
            .limit(limit)
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

        try await client
            .from("user_profiles")
            .update(fields)
            .eq("id", value: userID)
            .execute()

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
            "location": AnyEncodable(userProfile.location ?? nil),
            "gym_memberships": AnyEncodable(userProfile.gym_memberships)
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
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to JPEG."])
        }

        let fileName = "\(userID.uuidString).jpg"
        let bucket = "profile_pictures"

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

                if let updatedProfile = try await fetchUserProfile(for: userID) {
                    await profileCache.store(updatedProfile, for: userID)
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

        let post = Post(
            id: nil,
            user_id: userID,
            content: content,
            created_at: Date()
        )

        try await client
            .from("posts")
            .insert(post)
            .select()
            .single()
            .execute()
    }
    
    func checkUserName(userName: String) async -> Bool {
        do {
            let result = try await client
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
    
    func fetchPosts(for userId: UUID) async throws -> [Post] {
        let posts = try await client
            .from("posts")
            .select()
            .eq("user_id", value: userId.uuidString)
            .order("created_at", ascending: false)
            .execute()
            .value as [Post]

        return posts
    }

    func fetchMyPosts() async throws -> [Post] {
        guard let userId = client.auth.currentUser?.id else {
            LOG.error("No authenticated user found")
            return []
        }
        
        return try await fetchPosts(for: userId)
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


    
    

}
