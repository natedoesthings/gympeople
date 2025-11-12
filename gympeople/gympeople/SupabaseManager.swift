//
//  SupabaseManager.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/11/25.
//

import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        client = SupabaseClient(
            supabaseURL: URL(string: "https://ahbfthtjmafiflvgrfug.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFoYmZ0aHRqbWFmaWZsdmdyZnVnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI5MTMzOTIsImV4cCI6MjA3ODQ4OTM5Mn0.ydRjSPqBIPGJHNUATO57GDcZYiYUKIRxn2Jx_H3UiuA"
        )
    }
}
