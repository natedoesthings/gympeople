//
//  LocalSearchRegionModifier.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/5/25.
//

import SwiftUI

struct LocalSearchRegionModifier: ViewModifier {
    @ObservedObject var service: LocalSearchService

    func body(content: Content) -> some View {
        content
            .task {
                await service.loadUserRegion()
            }
    }
}
