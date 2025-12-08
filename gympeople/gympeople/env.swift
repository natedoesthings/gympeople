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
    
    // Cloudflare R2 / S3 API Configuration
    static var r2ApiEndpoint: String {
        Bundle.main.object(forInfoDictionaryKey: "R2_API_ENDPOINT") as? String ?? ""
    }
    
    static var r2UploadSecret: String {
        Bundle.main.object(forInfoDictionaryKey: "R2_UPLOAD_SECRET") as? String ?? ""
    }
    
    static var r2AccessKeyId: String {
        Bundle.main.object(forInfoDictionaryKey: "R2_ACCESS_KEY_ID") as? String ?? ""
    }
    
    static var r2SecretAccessKey: String {
        Bundle.main.object(forInfoDictionaryKey: "R2_SECRET_ACCESS_KEY") as? String ?? ""
    }
}
