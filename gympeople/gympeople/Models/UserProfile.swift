//
//  UserProfile.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import Foundation
import CoreLocation

struct UserProfile: Codable, Identifiable {
    let id: UUID
    let first_name: String
    let last_name: String
    let user_name: String
    let email: String
    let date_of_birth: Date
    let phone_number: String
    let location: String?
    let gym_memberships: [String]?
    let created_at: Date?
}
