//
//  PostsView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/2/25.
//

import SwiftUI

struct PostsView: View {
    @ObservedObject var postsVM: ListViewModel<Post>
    @State private var fetched: Bool = false
    
    var feed: Bool = false
    
    var body: some View {
        HiddenScrollView {
            LazyVStack {
                ForEach(postsVM.items, id: \.self) { post in
                    PostCard(
                        post: post,
                        feed: feed
                    )
                    
                    Divider()
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 100)
        }
        .overlay { if postsVM.isLoading { ProgressView() } }
        .task {
            if !fetched {
                await postsVM.load()
            }
            fetched = true
        }
        .listErrorAlert(vm: postsVM, onRetry: { await postsVM.refresh() })
    }
}
