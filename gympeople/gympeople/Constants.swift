//
//  Constants.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/18/25.
//
import Foundation

let GYMS = [
    "Planet Fitness",
    "LA Fitness",
    "YMCA",
    "Gold’s Gym",
    "Crunch Fitness",
    "Anytime Fitness"
    
]

let POSTS = [Post(id: UUID(), user_id: UUID(), content: "Morning cardio at the track. 5K in 24:10. Progress! Also started incorporating some mobility drills.", created_at: Date().addingTimeInterval(-60 * 7), updated_at: Date(), like_count: 123123, comment_count: 32)]

// let DUMMY_USER_PROFILE =
