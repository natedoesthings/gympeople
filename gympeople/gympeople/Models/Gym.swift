//
//  Gym.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/28/25.
//

import Foundation
import MapKit

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
    let distance_meters: Double?
    let verification_status: MembershipVerificationStatus?
    let document_url: String?
}

extension Gym {
    static func from(mapItem: MKMapItem) -> Gym {
        return Gym(
            id: UUID(),
            name: mapItem.name,
            phone_number: mapItem.phoneNumber,
            url: mapItem.url?.absoluteString,
            latitude: mapItem.location.coordinate.latitude,
            longitude: mapItem.location.coordinate.longitude,
            address: mapItem.addressRepresentations?.fullAddress(
                includingRegion: true,
                singleLine: false
            ),
            member_count: 0,
            post_count: 0,
            distance_meters: nil,
            verification_status: .unverified,
            document_url: nil
        )
    }
    
    static func payload(mapItem: MKMapItem) -> [String: AnyEncodable] {
        return [
            "name": AnyEncodable(mapItem.name),
            "address": AnyEncodable(mapItem.addressRepresentations?.fullAddress(includingRegion: true, singleLine: false)),
            "latitude": AnyEncodable(mapItem.location.coordinate.latitude),
            "longitude": AnyEncodable(mapItem.location.coordinate.longitude),
            "url": AnyEncodable(mapItem.url?.absoluteString),
            "phone_number": AnyEncodable(mapItem.phoneNumber)
        ]
    }
    
    static func payload(gym: Gym) -> [String: AnyEncodable] {
        return [
            "name": AnyEncodable(gym.name),
            "address": AnyEncodable(gym.address),
            "latitude": AnyEncodable(gym.latitude),
            "longitude": AnyEncodable(gym.longitude),
            "url": AnyEncodable(gym.url),
            "phone_number": AnyEncodable(gym.phone_number)
        ]
    }
}
