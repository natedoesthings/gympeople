//
//  AppTheme.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/22/25.
//

enum ProfileTab: String, CaseIterable, Identifiable {
    case posts = "Posts"
    case mentions = "Mentions"
    
    var id: String { self.rawValue }
}
