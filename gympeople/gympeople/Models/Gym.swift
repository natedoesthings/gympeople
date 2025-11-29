//
//  Gym.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/28/25.
//

import Foundation

struct Gym: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String?
    let phone_number: String?
    let url: String?
    let latitude: Double
    let longitude: Double
    let address: String?
    let member_count: Int
    let post_count: Int
}
