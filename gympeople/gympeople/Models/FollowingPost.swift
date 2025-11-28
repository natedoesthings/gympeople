//
//  FollowingPost.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/27/25.
//

import Foundation

struct FollowingPost: Decodable, Identifiable {
    let post_id: UUID
    let post_content: String
    let post_created_at: Date
    
    var id: UUID { post_id }

    let post_user_id: UUID
    let user_name: String
    let first_name: String
    let last_name: String
    let pfp_url: String?
}
