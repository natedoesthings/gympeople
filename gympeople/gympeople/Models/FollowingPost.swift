//
//  FollowingPost.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/27/25.
//

import Foundation

struct FollowingPost: Decodable, Identifiable {
    let post_id: UUID
    let post_user_id: UUID
    let content: String
    let created_at: Date
    let updated_at: Date
    let like_count: Int
    let comment_count: Int
    
    let user_name: String
    let first_name: String
    let last_name: String
    let pfp_url: String?
    
    var id: UUID { post_id }
}
