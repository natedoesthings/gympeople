//
//  GymsView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/26/25.
//

import SwiftUI
import MapKit

enum DiscoverCategory: String, CaseIterable {
    case gyms = "Gyms"
    case people = "People"
}

struct DiscoverView: View {
    @EnvironmentObject var tabBarManager: TabBarVisibilityManager
    @StateObject var nearbyGymsVM = ListViewModel<Gym>(fetcher: { try await SupabaseManager.shared.fetchMyNearbyGyms() })
    @StateObject var userGymsVM = ListViewModel<Gym>(fetcher: { try await SupabaseManager.shared.fetchMyGymMemberships() })
    @StateObject var nearbyUsersVM = ListViewModel<UserProfile>(fetcher: { try await SupabaseManager.shared.fetchMyNearbyUsers() })
    
    @State private var selectedCategory: DiscoverCategory = .gyms
    @State private var gymTab: GymsViewTab = .nearby
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 16) {
                    Text("Discover")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    
                    // Category Selector
                    HStack(spacing: 12) {
                        ForEach(DiscoverCategory.allCases, id: \.self) { category in
                            Button {
                                withAnimation(.spring(duration: 0.3)) {
                                    selectedCategory = category
                                }
                            } label: {
                                Text(category.rawValue)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(
                                        selectedCategory == category
                                        ? Color("BrandOrange")
                                        : Color(.systemGray6)
                                    )
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .background(Color(.systemBackground))
                .padding(.bottom, 12)
                
                // Content based on selected category
                if selectedCategory == .gyms {
                    gymsContent
                } else {
                    peopleContent
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .onChange(of: selectedCategory) { _, _ in
            tabBarManager.reset()
        }
        .onChange(of: gymTab) { _, _ in
            tabBarManager.reset()
        }
    }
    
    // MARK: - Gyms Content
    private var gymsContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Gym Tabs
            HiddenScrollView(.horizontal, trackScrollForTabBar: false) {
                HStack(spacing: 20) {
                    gymTabButton(.nearby, title: "Nearby")
                    gymTabButton(.trending, title: "Trending")
                    gymTabButton(.userGyms, title: "Your Gyms")
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
            }
            .background(Color(.systemBackground))
            
            // Gym Views
            switch gymTab {
            case .userGyms:
                UserGymsView(gymsVM: userGymsVM)
            case .nearby:
                NearbyGymsView(nearbyGymsVM: nearbyGymsVM)
            case .trending:
                TrendingGymsView(nearbyGymsVM: nearbyGymsVM)
            }
        }
    }
    
    private func gymTabButton(_ tab: GymsViewTab, title: String) -> some View {
        Button {
            withAnimation(.spring(duration: 0.25)) {
                gymTab = tab
            }
        } label: {
            VStack(spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(gymTab == tab ? Color("BrandOrange") : .secondary)
                
                if gymTab == tab {
                    Capsule()
                        .fill(Color("BrandOrange"))
                        .frame(height: 3)
                        .transition(.scale)
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(height: 3)
                }
            }
        }
    }
    
    // MARK: - People Content
    private var peopleContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Nearby Users")
                .font(.title3)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
                .padding(.top, 8)
            
            HiddenScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(nearbyUsersVM.items, id: \.self) { user in
                        UserDiscoverCard(profile: user)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(.top, 8)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80)
            }
        }
        .overlay { if nearbyUsersVM.isLoading { ProgressView() } }
        .task {
            if !nearbyUsersVM.fetched {
                await nearbyUsersVM.load()
            }
        }
        .refreshable {
            await nearbyUsersVM.refresh()
        }
        .listErrorAlert(vm: nearbyUsersVM, onRetry: { await nearbyUsersVM.refresh() })
    }
}

// MARK: - User Discover Card

struct UserDiscoverCard: View {
    let profile: UserProfile
    @State private var hasLoadedAvatar: Bool = false
    
    var body: some View {
        NavigationLink {
            ProfileContentView(userProfile: profile, hasLoadedAvatar: $hasLoadedAvatar)
        } label: {
            HStack(spacing: 16) {
                AvatarView(url: profile.pfp_url) {
                    hasLoadedAvatar = true
                }
                .frame(width: 56, height: 56)
                .overlay(
                    Circle()
                        .stroke(Color("BrandOrange").opacity(0.2), lineWidth: 2)
                )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(profile.first_name) \(profile.last_name)")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("@\(profile.user_name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
//                    if let distance = profile.distance_miles {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.caption2)
                            Text(String(format: "%.1f mi away", 2))
                                .font(.caption)
                        }
                        .foregroundStyle(Color("BrandOrange"))
//                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
    }
}
