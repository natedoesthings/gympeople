//
//  gympeopleApp.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/11/25.
//

import SwiftUI

@main
struct gympeopleApp: App {
    @StateObject var authVM = AuthViewModel()
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(authVM) 
                .onOpenURL { url in
                    Task { await authVM.handleAuthCallback(url: url) }
                }
        }
    }
}
