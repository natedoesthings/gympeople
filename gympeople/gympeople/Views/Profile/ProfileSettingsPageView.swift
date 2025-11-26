//
//  ProfileSettingsPageView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/19/25.
//

import SwiftUI

struct ProfileSettingsPageView: View {
    @EnvironmentObject var authVM: AuthViewModel
    let userProfile: UserProfile
    
    @State private var showLogoutAlert: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                AvatarView(url: userProfile.pfp_url)
                    .frame(width: 80, height: 80)
                
                Text("\(userProfile.first_name) \(userProfile.last_name)")
                    .font(.title2)
                
                Text("@\(userProfile.user_name)")
                    .fontWeight(.light)
                
                Button {
                    showLogoutAlert = true
                } label: {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(.error)
                        .cornerRadius(20)
                }
                .frame(width: 100)
                
            }
            ScrollView {
                Section(header: header("Content")) {
                    Button {
                        
                    } label: {
                        HStack {
                            sectionItem("Favorites", icon: "plus")
                            
                            Spacer()
                            Image(systemName: "greaterthan")
                                .foregroundStyle(.invertedPrimary)
                            
                        }
                    }
                    
                    Button {
                        
                    } label: {
                        HStack {
                            sectionItem("Downloads", icon: "plus")
                            
                            Spacer()
                            Image(systemName: "greaterthan")
                                .foregroundStyle(.invertedPrimary)
                            
                        }
                    }
                    
                }
                
                Section(header: header("Preferences")) {
                    Button {
                        
                    } label: {
                        HStack {
                            sectionItem("Language", icon: "plus")
                            
                            Spacer()
                            Image(systemName: "greaterthan")
                                .foregroundStyle(.invertedPrimary)
                            
                        }
                    }
                    
                    Button {
                        
                    } label: {
                        HStack {
                            sectionItem("Notifications", icon: "plus")
                            
                            Spacer()
                            Image(systemName: "greaterthan")
                                .foregroundStyle(.invertedPrimary)
                            
                        }
                    }
                    
                    Button {
                        
                    } label: {
                        HStack {
                            sectionItem("Theme", icon: "plus")
                            
                            Spacer()
                            Image(systemName: "greaterthan")
                                .foregroundStyle(.invertedPrimary)
                            
                        }
                    }
                    
                    Button {
                        
                    } label: {
                        HStack {
                            sectionItem("Background Play", icon: "plus")
                            
                            Spacer()
                            Image(systemName: "greaterthan")
                                .foregroundStyle(.invertedPrimary)
                            
                        }
                    }
                    
                    Button {
                        
                    } label: {
                        HStack {
                            sectionItem("Download via Wi-Fi", icon: "plus")
                            
                            Spacer()
                            Image(systemName: "greaterthan")
                                .foregroundStyle(.invertedPrimary)
                            
                        }
                    }
                    
                    Button {
                        
                    } label: {
                        HStack {
                            sectionItem("Autoplay", icon: "plus")
                            
                            Spacer()
                            Image(systemName: "greaterthan")
                                .foregroundStyle(.invertedPrimary)
                            
                        }
                    }
                }
                    
            }
            
        }
        .padding()
        .alert(isPresented: $showLogoutAlert) {
            Alert(
                title: Text("Log out of @\(userProfile.user_name)?"),
                message: Text("Any ongoing activity will stop and your profile will no longer be active on this device."),
                primaryButton: .cancel(Text("Cancel")),
                secondaryButton: .destructive(Text("Logout"), action: {
                    Task {
                        await authVM.signOut()
                    }
                })
            )
        }
        
    }
    
    @ViewBuilder
    private func header(_ content: String) -> some View {
        Text(content)
            .font(.system(size: 15))
            .fontWeight(.semibold)
            .foregroundStyle(Color(.systemGray))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top)
    }
    
    @ViewBuilder
    private func sectionItem(_ name: String, icon: String) -> some View {
        Image(systemName: icon)
            .resizable()
            .foregroundStyle(Color(.systemGray))
            .frame(width: 16, height: 16)
            .padding(12)
            .background(
                    Circle()
                        .fill(Color(.systemGray6))
                )
            
        Text(name)
            .foregroundStyle(.invertedPrimary)
            .padding(.horizontal)
    }
}

//#Preview {
//         let userProfile = UserProfile.init(id: UUID(), first_name: "Nate", last_name: "dasd", user_name: "lajsfdslf", biography: "ds", email: "dsd", date_of_birth: Date(), phone_number: "", created_at: Date())
//    
//    ProfileSettingsPageView(userProfile: userProfile)
//}
