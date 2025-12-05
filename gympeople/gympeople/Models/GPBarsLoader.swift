//
//  GPBarsLoader.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/4/25.
//
import SwiftUI

struct GPBarsLoader: View {
    @State private var anim = false

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<4) { index in
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.accentColor)
                    .frame(width: 6, height: anim ? 28 : 12)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever()
                        .delay(0.1 * Double(index)),
                        value: anim
                    )
            }
        }
        .onAppear { anim = true }
    }
}


struct LoaderOverlay: ViewModifier {
    let isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isLoading)
                .blur(radius: isLoading ? 2 : 0)
            
            if isLoading {
                Color.black.opacity(0.2).ignoresSafeArea()
                GPBarsLoader()      // <-- swap for GPDotsLoader() if you want
                    .padding(40)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 10)
            }
        }
    }
}

extension View {
    func loading(_ isLoading: Bool) -> some View {
        modifier(LoaderOverlay(isLoading: isLoading))
    }
}
