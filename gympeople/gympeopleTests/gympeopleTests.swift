//
//  gympeopleTests.swift
//  gympeopleTests
//
//  Created by Nathanael Tesfaye on 11/13/25.
//

import XCTest
@testable import gympeople
import Supabase
import CoreLocation

final class AuthViewModelTests: XCTestCase {
    
    private var authVM: AuthViewModel!

    override func setUp() async throws {
        try await super.setUp()
        authVM = await AuthViewModel()
    }

    override func tearDown() async throws {
        authVM = nil
        try await super.tearDown()
    }

    private var validTestEmail: String {
        "test+\(UUID().uuidString.prefix(8))@example.com"
    }
    private let validTestPassword = "Password123!"
    private var inValidTestEmail: String {
        "test+\(UUID().uuidString.prefix(8))example.com"
    }
    private let inValidTestPassword = "Password123"
    private var userID: UUID?
    
    // MARK: Test Cases
    func testValidEmailSignUp () async throws {
        var testEmail: String {
            "test+\(UUID().uuidString.prefix(8))@example.com"
        }
        let testPassword = "Password123!"
        
        do {
            await authVM.signUpWithEmail(email: validTestEmail, password: validTestEmail, firstName: "Test", lastName: "User")
            
            // 5 seconds
            try await Task.sleep(nanoseconds: 5_000_000_000)

            // Read MainActor-isolated properties on the MainActor first
            let isSignedIn = await MainActor.run { authVM.isSignedIn }
            let firstName = await MainActor.run { authVM.firstName }
            let needsOnboarding = await MainActor.run { authVM.needsOnboarding }

            // Now assert on plain values (non-isolated)
            XCTAssertTrue(isSignedIn, "User should be signed in after sign up")
            XCTAssertFalse(firstName.isEmpty, "User name should not be empty")
            XCTAssertTrue(needsOnboarding, "New user should require onboarding")
            
            await authVM.signOut()
            
        } catch {
            XCTFail("Failed to save profile: \(error)")
        }
    }

    func testInValidPasswordSignUp () async throws {
        do {
            
            await authVM.signUpWithEmail(email: validTestEmail, password: inValidTestPassword, firstName: "Test", lastName: "User")
            
            // 5 seconds
            try await Task.sleep(nanoseconds: 5_000_000_000)

            // Read MainActor-isolated properties on the MainActor first
            let isSignedIn = await MainActor.run { authVM.isSignedIn }
            let firstName = await MainActor.run { authVM.firstName }
            let needsOnboarding = await MainActor.run { authVM.needsOnboarding }
            let loginError = await MainActor.run { authVM.loginError }

            // deafult values, should not change
            XCTAssertNotNil(loginError, "there should be an error")
            XCTAssertFalse(isSignedIn, "user should not be signed in")
            XCTAssertTrue(firstName.isEmpty, "User name should be empty")
            XCTAssertTrue(needsOnboarding, "onboarding status does not change")
            
        } catch {
            XCTFail("Failed to save profile: \(error)")
        }
    }
    
    func testInValidEmailSignUp () async throws {
        do {
            
            await authVM.signUpWithEmail(email: inValidTestEmail, password: validTestPassword, firstName: "Test", lastName: "User")
            
            // 5 seconds
            try await Task.sleep(nanoseconds: 5_000_000_000)

            // Read MainActor-isolated properties on the MainActor first
            let isSignedIn = await MainActor.run { authVM.isSignedIn }
            let firstName = await MainActor.run { authVM.firstName }
            let needsOnboarding = await MainActor.run { authVM.needsOnboarding }
            let loginError = await MainActor.run { authVM.loginError }

            // deafult values, should not change
            XCTAssertNotNil(loginError, "there should be an error")
            XCTAssertFalse(isSignedIn, "user should not be signed in")
            XCTAssertTrue(firstName.isEmpty, "User name should be empty")
            XCTAssertTrue(needsOnboarding, "onboarding status does not change")
            
        } catch {
            XCTFail("Failed to save profile: \(error)")
        }
    }
}


final class SupabaseTests: XCTestCase {
    let manager = SupabaseManager.shared

    private var testEmail: String {
        "test\(UUID().uuidString.prefix(8))@example.com"
    }
    
    private let testPassword = "Password123!"
    
    override func setUp() async throws {
        LOG.info("Setting up...")
        try await super.setUp()
        try await manager.client.auth.signOut()
    }
    
    override func tearDown() async throws {
        LOG.info("Tearing down...")
        
        defer { super.tearDown() }
        
        do {
            if let userID = await manager.client.auth.currentUser?.id {
                LOG.info("Cleaning up test user: \(userID)")
                
                try await manager.client
                    .from("user_profiles")
                    .delete()
                    .eq("id", value: userID)
                    .execute()
                
                try await manager.client.auth.signOut()
            }
        } catch {
            LOG.error("Cleanup failed: \(error)")
        }
    }
    
    // MARK: Test cases
    func testSavingFetchingProfile() async throws {
        do {
            LOG.debug("Before signing up \(testEmail)")
            
            let signUpResult = try await manager.client.auth.signUp(
                email: testEmail,
                password: testPassword
            )
            
            try await Task.sleep(nanoseconds: 500_000_000)
            
            if let session = signUpResult.session {
                try await manager.client.auth.setSession(accessToken: session.accessToken, refreshToken: session.refreshToken)
            } else {
                LOG.notice("No session returned by signUp, reauthenticating manually...")
                try await manager.client.auth.signIn(email: testEmail, password: testPassword)
            }
            
            let user = signUpResult.user
            LOG.info("Created test user with id: \(user.id)")
            LOG.info("Created test email with email: \(testEmail)")
            
            guard let user = await manager.client.auth.currentUser else {
                XCTFail("No authenticated user found")
                return
            }
                
            let userEmail = user.email ?? ""
            LOG.debug("Current user \(user.id)")
            LOG.debug("Current email \(userEmail)")
            
            do {
                try await manager.saveUserProfile(
                    firstName: "Test",
                    lastName: "User",
                    userName: "testuser123",
                    email: userEmail,
                    dob: Date(timeIntervalSince1970: 0),
                    phone: "1234567890",
                    location: "Nashville, TN",
                    gyms: ["Planet Fitness", "YMCA"]
                )
            } catch {
                XCTFail("Failed to save profile: \(error)")
            }
            
            LOG.info("Inserted profile for \(userEmail)")

            let fetchedProfile = try await manager.fetchUserProfile()
            XCTAssertNotNil(fetchedProfile, "Expected fetched profile to exist")
            
            guard let profile = fetchedProfile else {
                XCTFail("No profile returned from fetchUserProfile()")
                return
            }
            
            XCTAssertEqual(profile.first_name, "Test")
            XCTAssertEqual(profile.last_name, "User")
            XCTAssertEqual(profile.phone_number, "1234567890")
            XCTAssertEqual(profile.location, "Nashville, TN")
            XCTAssertEqual(profile.gym_memberships ?? [], ["Planet Fitness", "YMCA"])
        
            
        } catch {
            XCTFail("Test failed: \(error)")
        }
    }
}
