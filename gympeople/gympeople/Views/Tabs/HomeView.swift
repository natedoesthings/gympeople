//
//  HomeView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/12/25.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        TabView {
            NavigationStack { WelcomeView() }
                .tabItem { Label("Home", systemImage: "house") }

            NavigationStack { ProfileView() }
                .tabItem { Label("Profile", systemImage: "person") }
        }
        
    }
}

struct WelcomeView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Welcome, \(authVM.userName)")
                .font(.title)
                .fontWeight(.bold)
            Button("Sign Out") {
                Task { await authVM.signOut() }
            }
            .foregroundColor(.red)
        }
    }
}
