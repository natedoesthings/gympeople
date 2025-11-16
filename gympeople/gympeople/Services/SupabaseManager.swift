//
//  SupabaseManager.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/11/25.
//

import Foundation
import Supabase
import CoreLocation

class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Env.supabaseURL)!,
            supabaseKey: Env.supabaseAnonKey
        )
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
        location: String,
        gyms: [String]
    ) async throws {
        let data: [String: AnyEncodable] = [
            "id": AnyEncodable(client.auth.currentUser?.id),
            "first_name": AnyEncodable(firstName),
            "last_name": AnyEncodable(lastName),
            "user_name": AnyEncodable(userName),
            "email": AnyEncodable(email),
            "date_of_birth": AnyEncodable(ISO8601DateFormatter().string(from: dob)),
            "phone_number": AnyEncodable(phone),
            "location": AnyEncodable(location.isEmpty ? nil : location),
            "gym_memberships": AnyEncodable(gyms)
        ]
        try await client.from("user_profiles").insert(data).execute()
    }

    func fetchUserProfile() async throws -> UserProfile? {
        guard let userID = client.auth.currentUser?.id else {
            print("No authenticated user found")
            return nil
        }
        
        let response = try await client
            .from("user_profiles")
            .select()
            .eq("id", value: userID)
            .single()
            .execute()
        
        let data = response.data
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ" // handles full timestamps
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try full ISO8601 first
            if let date = ISO8601DateFormatter().date(from: dateString) {
                return date
            }
            // Try yyyy-MM-dd
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

        let profile = try decoder.decode(UserProfile.self, from: data)
        return profile
    }
    
    func updateUserName(newUserName: String) async throws {
        guard let userID = client.auth.currentUser?.id else {
            print("No authenticated user found")
            return
        }

        try await client
            .from("user_profiles")
            .update(["user_name": newUserName])
            .eq("id", value: userID)
            .execute()
    }

}
