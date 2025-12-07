//
//  UserGyms.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/30/25.
//

import SwiftUI

struct UserGymsView: View {
    @ObservedObject var gymsVM: ListViewModel<Gym>
    
    var body: some View {
        HiddenScrollView {
            LazyVStack {
                ForEach(gymsVM.items, id: \.self) { gym in
                    NavigationLink {
                        GymView(gym: gym)
                    } label: {
                        GymCard(gym: gym)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Color.clear.frame(height: 80)
        }
        .padding()
        .overlay { if gymsVM.isLoading { ProgressView() } }
        .task {
            if !gymsVM.fetched {
                await gymsVM.load()
            }
        }
        .refreshable {
            await gymsVM.refresh()
        }
        .listErrorAlert(vm: gymsVM, onRetry: { await gymsVM.refresh() })
    }
    
}
