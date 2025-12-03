//
//  Trending.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/30/25.
//

import SwiftUI

struct TrendingGymsView: View {
    @ObservedObject var nearbyGymsVM: ListViewModel<Gym>
    var sortedGyms: [Gym] {
        nearbyGymsVM.items.sorted { $0.post_count > $1.post_count }
    }

    var body: some View {
        HiddenScrollView {
            LazyVStack {
                ForEach(sortedGyms, id: \.self) { gym in
                    NavigationLink {
                        GymView(gym: gym)
                    } label: {
                        GymCard(gym: gym)
                    }
                }
            }
        }
        .padding()
        .task {
            await nearbyGymsVM.load()
        }
        .refreshable {
            await nearbyGymsVM.refresh()
        }
        .listErrorAlert(vm: nearbyGymsVM, onRetry: { await nearbyGymsVM.refresh() })
        
    }
}
