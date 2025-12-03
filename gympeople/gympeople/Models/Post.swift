//
//  NearbyPost.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/23/25.
//

import Foundation

struct Post: Decodable, Identifiable, Hashable {
    let id: UUID
    let user_id: UUID
    let content: String
    let created_at: Date
    let updated_at: Date
    var like_count: Int
    var comment_count: Int
    var is_liked: Bool
    let gym_id: UUID?

    let author_first_name: String
    let author_last_name: String
    let author_user_name: String
    let author_pfp_url: String?
}
