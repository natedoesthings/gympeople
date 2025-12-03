//
//  UserRow.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/1/25.
//

import SwiftUI

struct UserRow: View {
    let profile: UserProfile
    
    var body: some View {
        NavigationStack {
            HStack(spacing: 12) {
                NavigationLink {
                    ProfileContentView(userProfile: profile)
                } label: {
                    AvatarView(url: profile.pfp_url)
                        .frame(width: 48, height: 48)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("@\(profile.user_name)")
                            .font(.headline)
                            .foregroundStyle(.invertedPrimary)
                        
                        Text("\(profile.first_name) \(profile.last_name)")
                            .font(.subheadline)
                            .foregroundStyle(Color(.systemGray))
                    }
                    
                    Spacer()
                }
            }
            .padding(.vertical, 4)
        }
    }
}
