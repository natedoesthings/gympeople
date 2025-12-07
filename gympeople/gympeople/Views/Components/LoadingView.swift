//
//  LoadingView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import SwiftUI

struct LoadingView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.standardPrimary
                .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Brand logo
                Image("gympeople_no_bg")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .opacity(isAnimating ? 1.0 : 0.6)
                
                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .invertedPrimary))
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    LoadingView()
}
