//
//  HomeView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/12/25.
//

import SwiftUI

struct HomeView: View {
    @State private var tabSelected: Tab = .home
    @State private var showPostView: Bool = false
    
    var body: some View {
        ZStack {
            TabView(selection: $tabSelected) {
                ExploreView().tag(Tab.home)
                EmptyView().tag(Tab.chat)
                GymsView().tag(Tab.gyms)
                ProfileView().tag(Tab.profile)
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
                    FeedView().tag(HomeViewTab.explore)
                    FollowingView().tag(HomeViewTab.following)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        
    }
}
