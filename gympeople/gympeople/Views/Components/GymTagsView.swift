//
//  GymTagsView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/2/25.
//

import SwiftUI

struct GymTagsView: View {
    @ObservedObject var gymsVM: ListViewModel<Gym>
    @State private var fetched: Bool = false
    
    var body: some View {
        HiddenScrollView(.horizontal) {
            HStack {
                ForEach(gymsVM.items, id: \.self) { gym in
                    GymTagButton(gymTagType: .gym(gym: gym))
                }
            }
            .padding(1)
        }
        .overlay { if gymsVM.isLoading { ProgressView() } }
        .task {
            Task {
                if !fetched {
                    await gymsVM.load()
                }
                
                fetched = true
            }
        }
        .listErrorAlert(vm: gymsVM, onRetry: { await gymsVM.refresh() })
    }
}
