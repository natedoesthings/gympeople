//
//  UserGyms.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/30/25.
//

import SwiftUI

struct UserGymsView: View {
    @State private var memberships: [Gym]?
    
    var body: some View {
        HiddenScrollView {
            LazyVStack {
                if let gyms = memberships {
                    ForEach(gyms, id: \.self) { gym in
                        NavigationLink {
                            GymView(gym: gym)
                        } label: {
                            GymCard(gym: gym)
                        }
                        
                    }
                }
                
            }
        }
        .padding()
        .onAppear {
            Task {
                memberships = await SupabaseManager.shared.fetchMyGymMemberships()
            }
        }
    }
    
    
}
