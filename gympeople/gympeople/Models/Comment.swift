//
//  Comment.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/3/25.
//

import Foundation

struct Comment: Decodable, Identifiable, Hashable {
    let id: UUID
    let post_id: UUID
    let user_id: UUID
    let parent_comment_id: UUID?
    
    let content: String
    let created_at: Date
    
    var like_count: Int
    var replies_count: Int
    var is_liked: Bool
    
    // Author info
    let author_first_name: String
    let author_last_name: String
    let author_user_name: String
    let author_pfp_url: String?
}

