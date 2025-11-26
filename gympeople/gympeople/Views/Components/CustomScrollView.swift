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
    let content: () -> Content

    init(
        _ axes: Axis.Set = .vertical,
        showsIndicators: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.showsIndicators = showsIndicators
        self.content = content
    }

    var body: some View {
        ScrollView(axes, showsIndicators: showsIndicators) {
            content()
        }
        .scrollIndicators(.hidden)   // <— your global modifier
    }
}
