//
//  gympeopleApp.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/11/25.
//

import SwiftUI
import UIKit

@main
struct GymPeopleApp: App {
    @StateObject var authVM = AuthViewModel()

//    init() {
//        applyGlobalUIFont()
//    }

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environmentObject(authVM)
//                .environment(\.font, .app(.body))
                .onOpenURL { url in
                    Task { await authVM.handleAuthCallback(url: url) }
                }
        }
    }
}

func applyGlobalUIFont() {
    let fontName = "RobotoMono-Regular"

    let bodyFont = UIFont(name: fontName, size: 17) ?? .systemFont(ofSize: 17)
    let largeTitleFont = UIFont(name: fontName, size: 34) ?? .systemFont(ofSize: 34)

    UILabel.appearance().font = bodyFont
    UITextField.appearance().font = bodyFont
//    UITextView.appearance().font = bodyFont
    UIButton.appearance().titleLabel?.font = bodyFont

    // Navigation Bar
    UINavigationBar.appearance().titleTextAttributes = [.font: bodyFont]
    UINavigationBar.appearance().largeTitleTextAttributes = [.font: largeTitleFont]

    // Bar buttons
    UIBarButtonItem.appearance().setTitleTextAttributes([.font: bodyFont], for: .normal)

    // Tab bar items
    UITabBarItem.appearance().setTitleTextAttributes([.font: bodyFont], for: .normal)
}

