//
//  FollowingView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/23/25.
//

import SwiftUI

struct FollowingView: View {
    @ObservedObject var followingPostsVM: ListViewModel<Post>
    @State private var showPostView: Bool = false
    @State private var fetched: Bool = false
    
    var body: some View {
        HiddenScrollView {
            LazyVStack {
                ForEach(followingPostsVM.items) { post in
                    PostCard(
                        post: post,
                        feed: true
                    )
                    .padding()
                    .padding(.vertical, -10)
                    
                    Divider()
                }
            }
        }
        .overlay { if followingPostsVM.isLoading { ProgressView() } }
        .task {
            Task {
                if !fetched {
                    await followingPostsVM.load()
                }
                
                fetched = true
            }
        }
        .listErrorAlert(vm: followingPostsVM, onRetry: { await followingPostsVM.refresh() })
        .refreshable {
            Task {
                await followingPostsVM.refresh()
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
    }
}
