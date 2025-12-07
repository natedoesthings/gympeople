//
//  ProfileCache.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import Foundation

/// Thread-safe cache for user profiles
actor ProfileCache {
    private var cachedProfile: UserProfile?
    private var cachedUserID: UUID?

    func get(for userID: UUID) -> UserProfile? {
        guard userID == cachedUserID else { return nil }
        return cachedProfile
    }

    func store(_ profile: UserProfile, for userID: UUID) {
        cachedUserID = userID
        cachedProfile = profile
    }

    func clear() {
        cachedProfile = nil
        cachedUserID = nil
    }
}
