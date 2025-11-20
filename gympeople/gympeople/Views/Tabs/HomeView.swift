//
//  HomeView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/12/25.
//

import SwiftUI

struct HomeView: View {
    @State private var tabSelected: Tab = .home
    
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
            
            HStack(spacing: 25) {
                Button {
                    tabSelected = .home
                } label: {
                    Image(systemName: tabSelected == .home ? "house.fill" : "house")
                        .font(.system(size: 35))
                }
                
                Button {
                    tabSelected = .chat
                } label: {
                    Image(systemName: tabSelected == .chat ? "message.fill" : "message")
                        .font(.system(size: 35))
                }
                
                Button {
                    tabSelected = .post
                } label: {
                    Image(systemName: tabSelected == .post ? "plus.circle.fill" : "plus.circle")
                        .font(.system(size: 35))
                }
                
                Button {
                    tabSelected = .memberships
                } label: {
                    Image(systemName: tabSelected == .memberships ? "wallet.pass.fill" : "wallet.pass")
                        .font(.system(size: 35))
                }
                
                Button {
                    tabSelected = .profile
                } label: {
                    Image(systemName: tabSelected == .profile ? "person.fill" : "person")
                        .font(.system(size: 35))
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        
    }
}

#Preview {
    HomeView()
}

struct WelcomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Welcome, \(authVM.firstName) \(authVM.lastName)")
                .font(.title)
                .fontWeight(.bold)
            Button("Sign Out") {
                Task { await authVM.signOut() }
            }
            .foregroundColor(.red)
        }
    }
}
