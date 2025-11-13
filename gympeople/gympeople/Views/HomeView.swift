//
//  HomeView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/12/25.
//

import SwiftUI

struct HomeView: View {
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
