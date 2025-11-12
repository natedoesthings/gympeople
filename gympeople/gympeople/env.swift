//
//  env.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/12/25.
//

import Foundation

struct Env {
    static var supabaseURL: String {
        Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String ?? ""
    }

    static var supabaseAnonKey: String {
        Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String ?? ""
    }
}
