//
//  GymMembersView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/1/25.
//

import SwiftUI

struct GymMembersView: View {
    let gym_id: UUID
    @State private var members: [UserProfile]?
    
    var body: some View {
        HiddenScrollView {
            LazyVStack {
                if let members = members {
                    ForEach(members, id: \.self) { member in
                        UserRow(profile: member)
                        Divider()
                    }
                } else {
                    Text("No members at this gym.")
                }
                
            }
        }
        .padding()
        .onAppear {
            Task {
                members = await SupabaseManager.shared.fetchGymMembers(for: gym_id)
            }
        }
    }
    
}
