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
    let location_lat: Double?
    let location_lng: Double?
    let manual_location: String?
    let gym_memberships: [String]?
    let created_at: Date?
    
    var coordinate: CLLocationCoordinate2D? {
        if let lat = location_lat, let lng = location_lng {
            return CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
        return nil
    }
}
