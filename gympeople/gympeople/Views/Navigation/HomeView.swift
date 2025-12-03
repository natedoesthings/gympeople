//
//  HomeView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/12/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var userProfilesVM = ListViewModel<UserProfile>(fetcher: { try await SupabaseManager.shared.fetchMyUserProfile() })
    
    @StateObject private var postsVM = ListViewModel<Post>(fetcher: { try await SupabaseManager.shared.fetchMyPosts() })
    
    @StateObject private var gymsVM = ListViewModel<Gym>(fetcher: { try await SupabaseManager.shared.fetchMyGymMemberships() })
    
    @State private var tabSelected: Tab = .home
    @State private var showPostView: Bool = false
    
    var body: some View {
        ZStack {
            TabView(selection: $tabSelected) {
                ExploreView(userProfilesVM: userProfilesVM).tag(Tab.home)
                EmptyView().tag(Tab.chat)
                GymsView(userGymsVM: gymsVM).tag(Tab.gyms)
                ProfileView(
                    userProfilesVM: userProfilesVM,
                    postsVM: postsVM,
                    gymsVM: gymsVM
                ).tag(Tab.profile)
            }
            .tabViewStyle(.page(indexDisplayMode: .never)) // hide default bar
            
            HStack {
                Group {
                    Button {
                        tabSelected = .home
                    } label: {
                        Image(systemName: tabSelected == .home ? "house.fill" : "house")
                            .font(.system(size: 24))
                    }
                    
                    Button {
                        tabSelected = .chat
                    } label: {
                        Image(systemName: tabSelected == .chat ? "message.fill" : "message")
                            .font(.system(size: 24))
                    }
                    
                    Button {
                        showPostView = true
                    } label: {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 24))
                    }
                    
                    Button {
                        tabSelected = .gyms
                    } label: {
                        Image(systemName: tabSelected == .gyms ? "wallet.pass.fill" : "wallet.pass")
                            .font(.system(size: 24))
                    }
                    
                    Button {
                        tabSelected = .profile
                    } label: {
                        Image(systemName: tabSelected == .profile ? "person.fill" : "person")
                            .font(.system(size: 24))
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal, 23)
            }
            .background(Color.standardPrimary)
            .frame(maxHeight: .infinity, alignment: .bottom)
            
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .sheet(isPresented: $showPostView) {
            PostView()
        }
        
    }
}

struct ExploreView: View {
    @StateObject var userProfilesVM: ListViewModel<UserProfile>
    
    @StateObject private var nearbyPostsVM = ListViewModel<Post>(fetcher: { try await SupabaseManager.shared.fetchNearbyPosts() })
    
    @StateObject private var followingPostsVM = ListViewModel<Post>(fetcher: { try await SupabaseManager.shared.fetchFollowingPosts() })
    
    @State private var homeTab: HomeViewTab = .explore
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Group {
                        Button {
                            homeTab = .explore
                        } label: {
                            Text("Explore")
                                .foregroundStyle(homeTab == .explore ? .brandOrange : Color(.systemGray4))
                        }
                        
                        Button {
                            homeTab = .following
                        } label: {
                            Text("Following")
                                .foregroundStyle(homeTab == .following ? .brandOrange : Color(.systemGray4))
                        }
                        
                    }
                    .font(Font.title.bold())
                    .padding(.trailing)
                    
                    Spacer()
                    
                    NavigationLink {
                        SearchView()
                    } label: {
                        Image(systemName: "magnifyingglass")
                    }
                }
                .padding()
                
                TabView(selection: $homeTab) {
                    FeedView(nearbyPostsVM: nearbyPostsVM, userProfilesVM: userProfilesVM).tag(HomeViewTab.explore)
                    FollowingView(followingPostsVM: followingPostsVM).tag(HomeViewTab.following)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        
    }
}
