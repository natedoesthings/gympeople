//
//  UserProfile.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import Foundation

struct UserProfile: Codable, Identifiable, Hashable {
    let id: UUID
    var first_name: String
    var last_name: String
    var user_name: String
    var biography: String?
    var email: String
    var date_of_birth: Date
    var phone_number: String
    var location: String
    var latitude: Double
    var longitude: Double
    var pfp_url: String?
    let created_at: Date
    var updated_at: Date?
    var push_token: String?
    var is_private: Bool
    let follower_count: Int
    let following_count: Int
    let post_count: Int
}

extension UserProfile {
    static func placeholder() -> UserProfile {
        return UserProfile(
            id: UUID(),
            first_name: "Nate",
            last_name: "Tes",
            user_name: "",
            biography: nil,
            email: "",
            date_of_birth: Date(),
            phone_number: "",
            location: "",
            latitude: 0,
            longitude: 0,
            pfp_url: nil,
            created_at: Date(),
            updated_at: Date(),
            is_private: false,
            follower_count: 0,
            following_count: 0,
            post_count: 0
            
        )
    }
}
