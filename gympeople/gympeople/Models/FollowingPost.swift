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
    let post_content: String
    let post_created_at: Date
    let post_updated_at: Date
    let post_like_count: Int
    let post_comment_count: Int
    let post_gym_id: UUID?
    
    let user_name: String
    let first_name: String
    let last_name: String
    let pfp_url: String?
    let is_liked: Bool
    
    var id: UUID { post_id }
}
