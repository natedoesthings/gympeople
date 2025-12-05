//
//  Constants.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/18/25.
//
import Foundation

let GYMS = [Gym(
    id: UUID(uuidString: "d7aa8a1e-9c1c-4af5-9cd1-92b58b37f48c")!,
    name: "Equinox Madison Avenue",
    phone_number: "(212) 751-0515",
    url: "https://www.equinox.com/clubs/new-york/madisonavenue",
    latitude: 40.764356,
    longitude: -73.969097,
    address: "520 Madison Ave, New York, NY 10022",
    member_count: 1784,
    post_count: 342,
    distance_meters: 1200
)]

let COMMENTS: [Comment] = [
    Comment(
        id: UUID(),
        post_id: UUID(),
        user_id: UUID(),
        parent_comment_id: nil,
        content: "This workout looks insane! 🔥",
        created_at: Date().addingTimeInterval(-3600), // 1 hour ago
        like_count: 4,
        replies_count: 0,
        is_liked: true,
        author_first_name: "Alex",
        author_last_name: "Johnson",
        author_user_name: "alexj",
        author_pfp_url: nil
    ),
    
    Comment(
        id: UUID(),
        post_id: UUID(),
        user_id: UUID(),
        parent_comment_id: nil,
        content: "Bro I need this routine fr 💪",
        created_at: Date().addingTimeInterval(-7200), // 2 hours ago
        like_count: 1,
        replies_count: 0,
        is_liked: false,
        author_first_name: "Sam",
        author_last_name: "Green",
        author_user_name: "samg",
        author_pfp_url: nil
    ),
    
    // Reply to the first comment
    Comment(
        id: UUID(),
        post_id: UUID(),
        user_id: UUID(),
        parent_comment_id: UUID(),
        content: "@alexj same here🔥🔥",
        created_at: Date().addingTimeInterval(-1800), // 30 minutes ago
        like_count: 0,
        replies_count: 0,
        is_liked: false,
        author_first_name: "David",
        author_last_name: "Chen",
        author_user_name: "dchen",
        author_pfp_url: nil
    ),
    
    // Another reply
    Comment(
        id: UUID(),
        post_id: UUID(),
        user_id: UUID(),
        parent_comment_id: UUID(),
        content: "Facts 😂 I need a training partner for this.",
        created_at: Date().addingTimeInterval(-900), // 15 minutes ago
        like_count: 2,
        replies_count: 0,
        is_liked: false,
        author_first_name: "Mia",
        author_last_name: "Lopez",
        author_user_name: "mlopez",
        author_pfp_url: nil
    ),
    
    // Top level comment
    Comment(
        id: UUID(),
        post_id: UUID(),
        user_id: UUID(),
        parent_comment_id: nil,
        content: "This is clean🔥🔥 keep posting these!",
        created_at: Date().addingTimeInterval(-20000), // ~5 hours ago
        like_count: 7,
        replies_count: 0,
        is_liked: true,
        author_first_name: "Sarah",
        author_last_name: "Park",
        author_user_name: "sparks",
        author_pfp_url: nil
    )
]


// let DUMMY_USER_PROFILE =
