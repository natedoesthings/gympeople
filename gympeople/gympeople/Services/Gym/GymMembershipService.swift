//
//  GymMembershipService.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import Foundation
import Supabase

protocol GymMembershipServiceProtocol {
    func insertGymMemberships(_ gyms: [Gym]) async throws
    func syncGymMemberships(gyms: [Gym]) async throws
    func fetchGymMemberships(for userId: UUID, lat: Double?, lon: Double?) async throws -> [Gym]
    func updateMembershipVerification(gymId: UUID, documentUrl: String) async throws
}

class GymMembershipService: GymMembershipServiceProtocol {
    private let client: SupabaseClient
    private let rpc: RPCRepository
    
    init(client: SupabaseClient) {
        self.client = client
        self.rpc = RPCRepository(client: client)
    }
    
    func insertGymMemberships(_ insertedGyms: [Gym]) async throws {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }
        
        var membershipPayloads: [[String: AnyEncodable]] = []

        for gym in insertedGyms {
            membershipPayloads.append([
                "user_id": AnyEncodable(currentUserId),
                "gym_id": AnyEncodable(gym.id.uuidString)
            ])
        }
        
        do {
            try await client
                .from("gym_memberships")
                .insert(membershipPayloads)
                .execute()
            
            LOG.notice("Inserted \(insertedGyms.count) memberships")
        } catch {
            LOG.error("Failed to insert memberships: \(error)")
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func syncGymMemberships(gyms: [Gym]) async throws {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }
        
        do {
            let _: EmptyResponse = try await rpc.call(
                "sync_gym_memberships",
                params: SyncGymMembershipsParams(
                    p_gym_ids: gyms.map { $0.id },
                    p_user_id: currentUserId
                )
            )
        } catch {
            LOG.error("Failed syncing memberships: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchGymMemberships(for userId: UUID, lat: Double? = nil, lon: Double? = nil) async throws -> [Gym] {
        do {
            let gyms: [Gym] = try await rpc.call(
                "fetch_gyms_for_user",
                params: FetchGymMembershipsParams(
                    p_user_id: userId,
                    user_lat: lat,
                    user_lon: lon
                )
            )
            
            return gyms
        } catch {
            LOG.error("Failed to find memberships: \(error)")
            if let decodingError = error as? DecodingError {
                LOG.error("Decoding error details: \(decodingError)")
            }
            throw error
        }
    }
    
    func updateMembershipVerification(gymId: UUID, documentUrl: String) async throws {
        guard let currentUserId = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }
        
        do {
            try await client
                .from("gym_memberships")
                .update([
                    "verification_status": AnyEncodable("pending"),
                    "document_url": AnyEncodable(documentUrl)
                ])
                .eq("user_id", value: currentUserId.uuidString)
                .eq("gym_id", value: gymId.uuidString)
                .execute()
            
            LOG.notice("Updated membership verification status to pending")
        } catch {
            LOG.error("Failed to update membership verification: \(error)")
            throw SupabaseErrorMapper.map(error)
        }
    }
}

// MARK: - Supporting Types

struct EmptyResponse: Codable {}

nonisolated
struct SyncGymMembershipsParams: Encodable, Sendable {
    let p_gym_ids: [UUID]
    let p_user_id: UUID
}

nonisolated
struct FetchGymMembershipsParams: Encodable, Sendable {
    let p_user_id: UUID
    let user_lat: Double?
    let user_lon: Double?

    enum CodingKeys: String, CodingKey { case p_user_id, user_lat, user_lon }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(p_user_id, forKey: .p_user_id)
        if let lat = user_lat { try c.encode(lat, forKey: .user_lat) } else { try c.encodeNil(forKey: .user_lat) }
        if let lon = user_lon { try c.encode(lon, forKey: .user_lon) } else { try c.encodeNil(forKey: .user_lon) }
    }
}
