//
//  RPCRepository.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import Foundation
import Supabase

/// Generic repository for making RPC calls to Supabase
class RPCRepository {
    private let client: SupabaseClient
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    /// Execute an RPC call with Encodable params and decode the response
    func call<P: Encodable, T: Decodable>(_ function: String, params: P) async throws -> T {
        do {
            let response: T = try await client.rpc(function, params: params).execute().value
            return response
        } catch {
            LOG.error("RPC call '\(function)' failed with error: \(error)")
            if let decodingError = error as? DecodingError {
                LOG.error("DecodingError details: \(decodingError)")
            }
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    /// Execute an RPC call with custom decoder
    func callWithDecoder<T: Decodable>(
        _ function: String,
        params: some Encodable,
        decoder: JSONDecoder
    ) async throws -> T {
        do {
            let response = try await client.rpc(function, params: params).execute()
            return try decoder.decode(T.self, from: response.data)
        } catch {
            throw SupabaseErrorMapper.map(error)
        }
    }
}
