//
//  ScrollOffsetPreference.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import SwiftUI
import Combine


// MARK: - Tab Bar Tracking Preference (separate from general scroll tracking)

struct TabBarScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat? = nil
    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        let next = nextValue()
        // Only update if next value is actually set (non-nil)
        if let next = next {
            value = next
        }
    }
}

// MARK: - Tab Bar Visibility Manager

class TabBarVisibilityManager: ObservableObject {
    @Published var isVisible: Bool = true
    
    private var lastScrollOffset: CGFloat = 0
    private let threshold: CGFloat = 15 // Minimum scroll distance to trigger hide/show
    private var hasInitialized: Bool = false
    
    func updateVisibility(for scrollOffset: CGFloat) {
        // Initialize on first call or after reset
        if !hasInitialized {
            lastScrollOffset = scrollOffset
            hasInitialized = true
            return
        }
        
        let delta = scrollOffset - lastScrollOffset
        
        // Only update if scrolled past threshold
        if abs(delta) > threshold {
            withAnimation(.easeInOut(duration: 0.25)) {
                if delta < 0 {
                    // minY becoming more negative = scrolling down (content moving up) - hide tab bar
                    isVisible = false
                } else {
                    // minY becoming less negative = scrolling up (content moving down) - show tab bar
                    isVisible = true
                }
            }
            
            lastScrollOffset = scrollOffset
        }
    }
    
    func reset() {
        hasInitialized = false
        lastScrollOffset = 0
        withAnimation(.easeInOut(duration: 0.25)) {
            isVisible = true
        }
    }
}

// MARK: - Environment Key

struct TabBarVisibilityManagerKey: EnvironmentKey {
    static let defaultValue = TabBarVisibilityManager()
}

extension EnvironmentValues {
    var tabBarVisibilityManager: TabBarVisibilityManager {
        get { self[TabBarVisibilityManagerKey.self] }
        set { self[TabBarVisibilityManagerKey.self] = newValue }
    }
}
