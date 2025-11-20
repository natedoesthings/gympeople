//
//  Post.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/19/25.
//

import Foundation

struct Post: Codable {
    let id: UUID?
    let user_id: UUID
    let content: String
    let created_at: String?
}
