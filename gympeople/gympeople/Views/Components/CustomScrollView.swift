//
//  CustomScrollView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/25/25.
//

import SwiftUI

struct HiddenScrollView<Content: View>: View {
    let axes: Axis.Set
    let showsIndicators: Bool
    let trackScrollForTabBar: Bool
    let content: () -> Content
    let coordinateSpaceID = UUID().uuidString
    
    @EnvironmentObject var tabBarManager: TabBarVisibilityManager

    init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = false,
        trackScrollForTabBar: Bool = true,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.trackScrollForTabBar = trackScrollForTabBar
        self.content = content
    }

    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            content()
                .background(
                    Group {
                        if trackScrollForTabBar && axes == .vertical {
                            GeometryReader { geometry in
                                let offset = geometry.frame(in: .named(coordinateSpaceID)).minY
                                return Color.clear
                                    .preference(
                                        key: TabBarScrollOffsetKey.self,
                                        value: offset
                                    )
                            }
                        } else {
                            Color.clear
                        }
                    }
                )
        }
        .coordinateSpace(name: coordinateSpaceID)
        .scrollIndicators(.hidden)
        .onPreferenceChange(TabBarScrollOffsetKey.self) { value in
            if let value = value {
                tabBarManager.updateVisibility(for: value)
            }
        }
    }
}
