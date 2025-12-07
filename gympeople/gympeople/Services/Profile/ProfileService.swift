//
//  ProfileService.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import Foundation
import Supabase

protocol ProfileServiceProtocol {
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
    ) async throws
    
    func fetchUserProfile(for userId: UUID) async throws -> UserProfile
    func fetchMyUserProfile(refresh: Bool) async throws -> UserProfile
    func searchUserProfiles(matching query: String, limit: Int) async throws -> [UserProfile]
    func updateUserProfile(fields: [String: AnyEncodable]) async throws
    func updateUserProfile(userProfile: UserProfile) async throws
    func checkUserName(userName: String) async -> Bool
    func clearCache() async
}

class ProfileService: ProfileServiceProtocol {
    private let client: SupabaseClient
    private let rpc: RPCRepository
    private let cache = ProfileCache()
    private let decoder = DateDecoderHelper.makeDecoder()
    
    init(client: SupabaseClient) {
        self.client = client
        self.rpc = RPCRepository(client: client)
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
        location: String
    ) async throws {
        guard let userId = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }
        
        let data: [String: AnyEncodable] = [
            "id": AnyEncodable(userId),
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
            "is_private": AnyEncodable(false)
        ]
        
        do {
            try await client.from("user_profiles").insert(data).execute()
        } catch {
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func fetchUserProfile(for userId: UUID) async throws -> UserProfile {
        LOG.debug("Fetching user profile for: \(userId)")
        
        do {
            let response = try await client
                .rpc("fetch_user_profile", params: ["p_user_id" : userId.uuidString])
                .single()
                .execute()
            
            let profile = try decoder.decode(UserProfile.self, from: response.data)
            return profile
        } catch {
            LOG.error("Error loading profile via RPC: \(error.localizedDescription)")
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func fetchMyUserProfile(refresh: Bool = false) async throws -> UserProfile {
        guard let userID = client.auth.currentUser?.id else {
            LOG.notice("No authenticated user found")
            throw AppError.unauthorized
        }

        if !refresh {
            if let cached = await cache.get(for: userID) {
                LOG.debug("Returning cached profile for current user")
                return cached
            }
        }

        let profile = try await fetchUserProfile(for: userID)
        await cache.store(profile, for: userID)
        
        return profile
    }

    func searchUserProfiles(matching query: String, limit: Int = 20) async throws -> [UserProfile] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }

        do {
            let response = try await client
                .from("user_profiles")
                .select()
                .or("user_name.ilike.%\(trimmedQuery)%,full_name.ilike.%\(trimmedQuery)%")
                .order("user_name", ascending: true)
                .execute()

            return try decoder.decode([UserProfile].self, from: response.data)
        } catch {
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func updateUserProfile(fields: [String: AnyEncodable]) async throws {
        guard let userID = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }
        
        LOG.debug("Updating profile fields: \(fields.keys)")
        
        do {
            try await client
                .from("user_profiles")
                .update(fields)
                .eq("id", value: userID)
                .execute()
            
            // Wait a bit for database to settle
            try await Task.sleep(nanoseconds: 250_000_000)
            
            // Refresh cache
            let updatedProfile = try await fetchUserProfile(for: userID)
            await cache.store(updatedProfile, for: userID)
        } catch {
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func updateUserProfile(userProfile: UserProfile) async throws {
        guard let userID = client.auth.currentUser?.id else {
            throw AppError.unauthorized
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

        do {
            try await client
                .from("user_profiles")
                .update(fields)
                .eq("id", value: userID)
                .execute()

            await cache.store(userProfile, for: userID)
        } catch {
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func checkUserName(userName: String) async -> Bool {
        do {
            // Check cache first
            if let userID = client.auth.currentUser?.id {
                if let cached = await cache.get(for: userID) {
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
            
            // Username exists
            return false
        } catch {
            LOG.error("Error checking username: \(error)")
            return true
        }
    }

    func clearCache() async {
        await cache.clear()
    }
}

