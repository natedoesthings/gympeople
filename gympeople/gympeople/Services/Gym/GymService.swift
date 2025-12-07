//
//  GymService.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import Foundation
import Supabase

protocol GymServiceProtocol {
    func insertGyms(_ gyms: [[String: AnyEncodable]]) async throws -> [Gym]
    func insertGyms(_ gyms: [Gym]) async throws -> [Gym]
    func fetchGymMembers(for gymId: UUID) async throws -> [UserProfile]
    func fetchNearbyGyms(lat: Double, lon: Double) async throws -> [Gym]
}

class GymService: GymServiceProtocol {
    private let client: SupabaseClient
    private let rpc: RPCRepository
    private let decoder = DateDecoderHelper.makeDecoder()
    
    init(client: SupabaseClient) {
        self.client = client
        self.rpc = RPCRepository(client: client)
    }
    
    func insertGyms(_ gyms: [[String: AnyEncodable]]) async throws -> [Gym] {
        guard !gyms.isEmpty else { return [] }
        
        do {
            let insertedGyms: [Gym] = try await client
                .from("gyms")
                .upsert(gyms, onConflict: "address")
                .select()
                .execute()
                .value
            
            LOG.notice("Inserted \(insertedGyms.count) gyms")
            return insertedGyms
        } catch {
            LOG.error("Failed to insert gyms: \(error)")
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func insertGyms(_ gyms: [Gym]) async throws -> [Gym] {
        guard !gyms.isEmpty else { return [] }
        
        do {
            let insertedGyms: [Gym] = try await client
                .from("gyms")
                .upsert(gyms, onConflict: "address")
                .select()
                .execute()
                .value
            
            LOG.notice("Inserted \(insertedGyms.count) gyms")
            return insertedGyms
        } catch {
            LOG.error("Failed to insert gyms: \(error)")
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func fetchGymMembers(for gymId: UUID) async throws -> [UserProfile] {
        do {
            let response = try await client
                .rpc("fetch_user_profiles_for_gym", params: ["p_gym_id": gymId.uuidString])
                .execute()
            
            return try decoder.decode([UserProfile].self, from: response.data)
        } catch {
            LOG.error("Error fetching gym members: \(error.localizedDescription)")
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    func fetchNearbyGyms(lat: Double, lon: Double) async throws -> [Gym] {
        LOG.info("Fetching nearby gyms")
        
        do {
            let gyms: [Gym] = try await rpc.call(
                "fetch_gyms_by_distance",
                params: FetchNearbyGymsParams(
                    user_lat: lat,
                    user_lon: lon,
                    radius_km: 30,
                    max_results: 20
                )
            )
            
            LOG.info("Fetched \(gyms.count) gyms")
            return gyms
        } catch {
            LOG.error("Error fetching nearby gyms: \(error.localizedDescription)")
            throw error
        }
    }
}

// MARK: - Supporting Types
nonisolated
private struct FetchNearbyGymsParams: Encodable {
    let user_lat: Double
    let user_lon: Double
    let radius_km: Int
    let max_results: Int
}
