//
//  gympeopleTests.swift
//  gympeopleTests
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import XCTest
@testable import gympeople
import Supabase

final class SupabaseTests: XCTestCase {

    let manager = SupabaseManager.shared

    // Generate unique credentials so the test can run repeatedly
    private var testEmail: String {
        "test+\(UUID().uuidString.prefix(8))@example.com"
    }
    private let testPassword = "Password123!"

    // Store created user ID for reference
    private var userID: UUID?

    override func setUp() async throws {
        try await super.setUp()
    }

    func testFullUserLifecycle() async throws {
        do {
            let signUpResult = try await manager.client.auth.signUp(
                email: testEmail,
                password: testPassword
            )
            
            let user = signUpResult.user
            userID = user.id
            print("Created test user with id:", user.id)

            let dummyProfile = UserProfile(
                id: user.id,
                full_name: "Test User",
                email: testEmail,
                date_of_birth: Date(timeIntervalSince1970: 0),
                phone_number: "1234567890",
                location_lat: 36.1627,
                location_lng: -86.7816,
                manual_location: "Nashville, TN",
                gym_memberships: ["Planet Fitness", "YMCA"],
                created_at: Date()
            )
            
            let data: [String: AnyEncodable] = [
                "id": AnyEncodable(user.id),
                "full_name": AnyEncodable(dummyProfile.full_name),
                "email": AnyEncodable(dummyProfile.email),
                "date_of_birth": AnyEncodable(ISO8601DateFormatter().string(from: dummyProfile.date_of_birth)),
                "phone_number": AnyEncodable(dummyProfile.phone_number),
                "location_lat": AnyEncodable(dummyProfile.location_lat),
                "location_lng": AnyEncodable(dummyProfile.location_lng),
                "manual_location": AnyEncodable(dummyProfile.manual_location ?? ""),
                "gym_memberships": AnyEncodable(dummyProfile.gym_memberships ?? [])
            ]

            try await manager.client.from("user_profiles").insert(data).execute()
            
            print("Inserted profile for \(dummyProfile.full_name)")

            let fetched = try await manager.client
                .from("user_profiles")
                .select()
                .eq("id", value: user.id)
                .single()
                .execute()

            let decoder = JSONDecoder()
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ" // handles full timestamps
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.locale = Locale(identifier: "en_US_POSIX")

            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)

                // Try full ISO8601 first
                if let date = ISO8601DateFormatter().date(from: dateString) {
                    return date
                }
                // Try yyyy-MM-dd
                if let date = formatter.date(from: dateString) {
                    return date
                }
                // Try yyyy-MM-dd (date-only)
                let shortFormatter = DateFormatter()
                shortFormatter.dateFormat = "yyyy-MM-dd"
                if let date = shortFormatter.date(from: dateString) {
                    return date
                }

                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Unrecognized date format: \(dateString)"
                )
            }

            let fetchedProfile = try decoder.decode(UserProfile.self, from: fetched.data)

            XCTAssertEqual(fetchedProfile.full_name, dummyProfile.full_name)
            XCTAssertEqual(fetchedProfile.phone_number, dummyProfile.phone_number)
            XCTAssertEqual(fetchedProfile.email, dummyProfile.email)
            print("Verified fetched profile matches inserted data:", fetchedProfile)

        } catch {
            XCTFail("Test failed: \(error)")
        }
    }
}
