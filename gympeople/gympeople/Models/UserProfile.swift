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
    var first_name: String
    var last_name: String
    var user_name: String
    var biography: String?
    var email: String
    var date_of_birth: Date
    var phone_number: String
    var location: String?
    var gym_memberships: [String]?
    var pfp_url: String?
    let created_at: Date
}
