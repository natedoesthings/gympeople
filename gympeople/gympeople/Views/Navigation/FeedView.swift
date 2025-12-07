//
//  FeedView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/6/25.
//
import SwiftUI

struct FeedView: View {
    @ObservedObject var userProfilesVM: ListViewModel<UserProfile>
    
    @StateObject private var nearbyPostsVM = ListViewModel<Post>(fetcher: { try await SupabaseManager.shared.fetchNearbyPosts() })
    
    @StateObject private var followingPostsVM = ListViewModel<Post>(fetcher: { try await SupabaseManager.shared.fetchFollowingPosts() })
    
    @State private var feedTab: FeedViewTab = .explore
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
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
                
                // Use conditional rendering instead of TabView for better data loading
                if feedTab == .explore {
                    ExploreView(nearbyPostsVM: nearbyPostsVM, userProfilesVM: userProfilesVM)
                } else {
                    FollowingView(followingPostsVM: followingPostsVM)
                }
            }
        }
        .task {
            // Ensure data loads when view appears
            if !nearbyPostsVM.fetched {
                await nearbyPostsVM.load()
            }
            if !followingPostsVM.fetched {
                await followingPostsVM.load()
            }
        }
        
    }
    
    
    

}
