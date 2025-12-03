//
//  GymMembersView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/1/25.
//

import SwiftUI

struct GymMembersView: View {
    @ObservedObject var userProfilesVM: ListViewModel<UserProfile>
    
    var body: some View {
        HiddenScrollView {
            LazyVStack {
                if !userProfilesVM.items.isEmpty {
                    ForEach(userProfilesVM.items, id: \.self) { member in
                        UserRow(profile: member)
                        Divider()
                    }
                } else {
                    Text("No members at this gym.")
                }
                
            }
        }
        .padding()
        .overlay { if userProfilesVM.isLoading { ProgressView() } }
        .task {
            await userProfilesVM.load()
        }
        .refreshable {
            await userProfilesVM.refresh()
        }
        .listErrorAlert(vm: userProfilesVM, onRetry: { await userProfilesVM.refresh() })
    }
    
}
