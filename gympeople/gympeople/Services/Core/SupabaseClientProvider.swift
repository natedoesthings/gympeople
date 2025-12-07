//
//  SupabaseClientProvider.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import Foundation
import Supabase

/// Provides a shared Supabase client instance
class SupabaseClientProvider {
    static let shared = SupabaseClientProvider()
    
    let client: SupabaseClient
    
    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: Env.supabaseURL)!,
            supabaseKey: Env.supabaseAnonKey
        )
    }
}
