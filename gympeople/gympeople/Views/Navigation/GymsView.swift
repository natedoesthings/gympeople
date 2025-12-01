//
//  GymsView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/26/25.
//

import SwiftUI
import MapKit

struct GymsView: View {
    @State private var nearbyGyms: [Gym]?
    @State private var gymTab: GymsViewTab = .nearby
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
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
                
                TabView(selection: $gymTab) {
                    NearbyGymsView(gyms: $nearbyGyms).tag(GymsViewTab.nearby)
                    TrendingGymsView(gyms: $nearbyGyms).tag(GymsViewTab.trending)
                    UserGymsView().tag(GymsViewTab.userGyms)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .onAppear {
                Task {
                    nearbyGyms = await SupabaseManager.shared.fetchMyNearbyGyms()
                }
            }
        }
        
    }

}


#Preview {
    GymsView()
}
