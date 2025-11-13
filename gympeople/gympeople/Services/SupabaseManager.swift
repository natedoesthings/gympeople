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
        name: String,
        email: String,
        dob: Date,
        phone: String,
        location: CLLocationCoordinate2D?,
        manualLocation: String,
        gyms: [String]
    ) async throws {
        let data: [String: AnyEncodable] = [
            "id": AnyEncodable(client.auth.currentUser?.id),
            "full_name": AnyEncodable(name),
            "email": AnyEncodable(email),
            "date_of_birth": AnyEncodable(ISO8601DateFormatter().string(from: dob)),
            "phone_number": AnyEncodable(phone),
            "location_lat": AnyEncodable(location?.latitude),
            "location_lng": AnyEncodable(location?.longitude),
            "manual_location": AnyEncodable(manualLocation.isEmpty ? nil : manualLocation),
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
        decoder.dateDecodingStrategy = .iso8601
        
        let profile = try decoder.decode(UserProfile.self, from: data)
        return profile
    }

}
