//
//  HomeView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/12/25.
//


import SwiftUI

struct GymPeopleView: View {
    @StateObject private var userProfileVM = ListViewModel<UserProfile>(fetcher: { try await SupabaseManager.shared.fetchMyUserProfile() })
    @State private var selectedFilter: UserFilter = .all
    @State private var tabSelected: Tab = .home
    @State private var showPostView: Bool = false


    var body: some View {
        ZStack {
            TabView(selection: $tabSelected) {
                HomeView(userProfileVM: userProfileVM, tabSelected: $tabSelected).tag(Tab.home)
                FeedView(userProfilesVM: userProfileVM).tag(Tab.feed)
                GymsView().tag(Tab.discover)
                ProfileView().tag(Tab.profile)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            floatingTabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showPostView) {
            PostView()
        }
        .task {
            if !userProfileVM.fetched {
                await userProfileVM.load()
            }
        }
    }
    
    
    // MARK: - Floating Tab Bar
    private var floatingTabBar: some View {
        HStack(spacing: 26) {

            tabButton(icon: "house", selectedIcon: "house.fill", tab: .home)
            tabButton(icon: "text.below.photo", selectedIcon: "text.below.photo.fill", tab: .feed)

            // Center Action
            Button {
                showPostView = true
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.invertedPrimary)
                    .frame(width: 52, height: 52)
                    .background(Color.brandOrange)
                    .clipShape(Circle())
                    .shadow(color: Color.brandOrange.opacity(0.5), radius: 10, x: 0, y: 6)
            }
            .offset(y: -18)

            tabButton(icon: "magnifyingglass",
                      selectedIcon: "magnifyingglass",
                      tab: .discover)

            tabButton(icon: "person",
                      selectedIcon: "person.fill",
                      tab: .profile)

        }
        .padding(.vertical, 14)
        .padding(.horizontal, 26)
        .background(
            Capsule()
                .fill(Color.standardPrimary.opacity(0.92))
        )
        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    
    private func tabButton(icon: String, selectedIcon: String, tab: Tab) -> some View {
        Button {
            tabSelected = tab
        } label: {
            Image(systemName: tabSelected == tab ? selectedIcon : icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(tabSelected == tab ? .invertedPrimary : .gray.opacity(0.6))
                .frame(width: 44, height: 44)
                .background(
                    tabSelected == tab
                    ? Color.invertedPrimary.opacity(0.12)
                    : Color.clear
                )
                .clipShape(Circle())
        }
    }

}



