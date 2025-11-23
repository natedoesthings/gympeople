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
            switch tabSelected {
            case .home:
                WelcomeView()
//                EmptyView()
            case .chat:
                EmptyView()
            case .post:
                EmptyView()
            case .memberships:
                EmptyView()
            case .profile:
                ProfileView()
//                EmptyView()
                
            }
            
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
                        Image(systemName: tabSelected == .post ? "plus.circle.fill" : "plus.circle")
                            .font(.system(size: 24))
                    }
                    
                    Button {
                        tabSelected = .memberships
                    } label: {
                        Image(systemName: tabSelected == .memberships ? "wallet.pass.fill" : "wallet.pass")
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
        .sheet(isPresented: $showPostView) {
            PostView()
        }
        
    }
}

// #Preview {
//    HomeView()
// }

enum HomeTab {
    case explore
    case following
}

struct WelcomeView: View {
    @State private var homeTab: HomeTab = .explore
    
    var body: some View {
        
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
            }
            .padding()
            
            switch homeTab {
            case .explore:
                FeedView()
            case .following:
                EmptyView()
//                FollowingView()
            }
        }
        
    }
}

struct FeedView: View {
    let posts: [Post] = POSTS
    
    var body: some View {
        ScrollView {
            LazyVStack {
                
                // Wanna say hi?
                Button {
                    
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        // Avatar
                        AvatarView(url: "")
                            .frame(width: 36, height: 36)
                        
                        // Main column
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text("Hi")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                    .foregroundStyle(.invertedPrimary)
                                
                                Spacer()
                                
                            }
                            
                            // Content
                            Text("Say something!")
                                .font(.body)
                                .foregroundStyle(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                                .foregroundStyle(Color(.systemGray))
                        }
                    }
    //                .padding(.vertical, 10)
                    .padding()
                }
                
                Divider()
                
                //                    if let posts = posts {
                ForEach(posts, id: \.self) { post in
                    PostCard(post: post, displayName: "nate", username: "datnigga", avatarURL: "")
                        .padding()
                        .padding(.vertical, -10)
                    
                    Divider()
                }
                //                    }
            }
        }
        
    }
}

#Preview {
    
    WelcomeView()
}
