//
//  Constants.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/18/25.
//
import Foundation

let POSTS = [Post(id: UUID(), user_id: UUID(), content: "Morning cardio at the track. 5K in 24:10. Progress! Also started incorporating some mobility drills.", created_at: Date().addingTimeInterval(-60 * 7), updated_at: Date(), like_count: 123123, comment_count: 32, is_liked: false, gym_id: nil)]

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

// let DUMMY_USER_PROFILE =
