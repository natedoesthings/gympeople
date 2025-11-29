//
//  Post.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/19/25.
//

import Foundation

struct Post: Codable, Identifiable, Hashable {
    let id: UUID
    let user_id: UUID
    let content: String
    let created_at: Date
    let updated_at: Date
    let like_count: Int
    let comment_count: Int
    var is_liked: Bool
}
