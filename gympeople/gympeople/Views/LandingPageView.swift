//
//  LandingPage.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/17/25.
//

import SwiftUI

struct LandingPageView: View {
    @EnvironmentObject var authVM: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack {
                    Image("gympeople_light_no_bg")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                    
                    
                    Text("Welcome to GymPeople!")
                        .font(.title2.bold())
                        .padding(.vertical, 5)
                    
                    Text("Find your Gym People and Workout Buddies for life!")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                
                NavigationLink {
                    // action
                    SignInView()
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("BrandOrange"))
                        .cornerRadius(20)
                }
                .frame(width: 300)
                .padding(.vertical, 40)
                
                
                
            }
            .padding()
        }
            
    }
}

#Preview {
    LandingPageView()
}
