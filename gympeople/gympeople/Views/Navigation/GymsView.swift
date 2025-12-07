//
//  GymsView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/26/25.
//

import SwiftUI
import MapKit

struct GymsView: View {
    @StateObject var nearbyGymsVM = ListViewModel<Gym>(fetcher: { try await SupabaseManager.shared.fetchMyNearbyGyms() })
    @StateObject var userGymsVM = ListViewModel<Gym>(fetcher: { try await SupabaseManager.shared.fetchMyGymMemberships() })
    @State private var gymTab: GymsViewTab = .nearby
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                HiddenScrollView(.horizontal) {
                    HStack {
                        Group {
                            Button {
                                gymTab = .nearby
                            } label: {
                                Text("Nearby")
                                    .foregroundStyle(gymTab == .nearby ? .brandOrange : Color(.systemGray4))
                            }
                            
                            Button {
                                gymTab = .trending
                            } label: {
                                Text("Trending")
                                    .foregroundStyle(gymTab == .trending ? .brandOrange : Color(.systemGray4))
                            }
                            
                            Button {
                                gymTab = .userGyms
                            } label: {
                                Text("Your Gyms")
                                    .foregroundStyle(gymTab == .userGyms ? .brandOrange : Color(.systemGray4))
                            }
                            
                        }
                        .font(Font.title.bold())
                        .padding(.trailing)
                    }
                    .padding([.leading, .trailing, .top])
                }
                
                switch gymTab {
                case .userGyms:
                    UserGymsView(gymsVM: userGymsVM)
                case .nearby:
                    NearbyGymsView(nearbyGymsVM: nearbyGymsVM)
                case .trending:
                    TrendingGymsView(nearbyGymsVM: nearbyGymsVM)
                }
                    
            }
            .ignoresSafeArea(edges: .bottom)
        }
        
    }

}
