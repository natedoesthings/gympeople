//
//  FeedView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/6/25.
//
import SwiftUI

struct FeedView: View {
    @StateObject private var userProfilesVM = ListViewModel<UserProfile>(fetcher: { try await SupabaseManager.shared.fetchMyUserProfile() })
    
    @StateObject private var nearbyPostsVM = ListViewModel<Post>(fetcher: { try await SupabaseManager.shared.fetchNearbyPosts() })
    
    @StateObject private var followingPostsVM = ListViewModel<Post>(fetcher: { try await SupabaseManager.shared.fetchFollowingPosts() })
    
    @State private var feedTab: FeedViewTab = .explore
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Group {
                        Button {
                            feedTab = .explore
                        } label: {
                            Text("Explore")
                                .foregroundStyle(feedTab == .explore ? .brandOrange : Color(.systemGray4))
                        }
                        
                        Button {
                            feedTab = .following
                        } label: {
                            Text("Following")
                                .foregroundStyle(feedTab == .following ? .brandOrange : Color(.systemGray4))
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
                
                TabView(selection: $feedTab) {
                    ExploreView(nearbyPostsVM: nearbyPostsVM, userProfilesVM: userProfilesVM).tag(FeedViewTab.explore)
                    FollowingView(followingPostsVM: followingPostsVM).tag(FeedViewTab.following)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
            }
        }
        
    }
    
    
    

}
