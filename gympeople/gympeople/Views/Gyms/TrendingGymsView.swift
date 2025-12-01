//
//  Trending.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/30/25.
//

import SwiftUI

struct TrendingGymsView: View {
    @Binding var gyms: [Gym]?
    
    var body: some View {
        HiddenScrollView {
            LazyVStack {
                if let gyms = gyms?
                    .sorted(by: { $0.post_count > $1.post_count }) 
                {
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
    }
}

