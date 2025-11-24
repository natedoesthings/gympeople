//
//  NearbyPost.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/23/25.
//

import Foundation

struct NearbyPost: Decodable, Identifiable {
    let post_id: UUID
    let post_user_id: UUID
    let content: String
    let created_at: Date
    let updated_at: Date?

    let author_first_name: String
    let author_last_name: String?
    let author_user_name: String
    let author_pfp_url: String?

    let distance_meters: Double

    var id: UUID { post_id }

    var displayName: String {
        if let last = author_last_name {
            return "\(author_first_name) \(last)"
        }
        return author_first_name
    }

    var distanceMiles: Double {
        distance_meters / 1609.34
    }
}
