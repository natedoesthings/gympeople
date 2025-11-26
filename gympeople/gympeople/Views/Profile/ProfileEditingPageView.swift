//
//  ProfileEditingPageView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/19/25.
//

import SwiftUI
import MapKit

struct ProfileEditingPageView: View {
    @Binding var userProfile: UserProfile
    @Environment(\.dismiss) var dismiss
    @FocusState private var locationFieldIsFocused: Bool
    
    let manager = SupabaseManager.shared
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Username")
                            .font(.caption)

                        HStack {
                            Text("@")
                                .foregroundColor(.gray)
                                .padding(.leading, 10)
                            
                            TextField("Username", text: $userProfile.user_name)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.vertical, 12)
                        }
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 2)
                        )
                        
                        Text("Bio")
                            .font(.caption)
                        
                        CustomTextField(
                            placeholder: "Bio",
                            field: Binding(
                            get: { userProfile.biography ?? "" },
                            set: { newValue in
                                userProfile.biography = newValue
                            }
                        ), systemName: "text.book.closed"
                        )
                        
                        
                        Text("First Name")
                            .font(.caption)
                        
                        CustomTextField(placeholder: "First Name", field: $userProfile.first_name, systemName: "person")
                        
                        Text("Last Name")
                            .font(.caption)
                        
                        CustomTextField(placeholder: "Last Name", field: $userProfile.last_name, systemName: "person.text.rectangle")
                        
                        Text("Location")
                            .font(.caption)
                        
                        NavigationLink {
                            LocationEditingView(location: $userProfile.location, latitude: $userProfile.latitude, longitude: $userProfile.longitude)
                        } label: {
                            HStack {
                                Image(systemName: "mappin")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 10)
                                
                                Text(userProfile.location)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundStyle(.invertedPrimary)
                            }
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 2)
                            )
                        }
                        
                        Text("Phone")
                            .font(.caption)
                        CustomTextField(placeholder: "e.g. 615-555-1234", field: $userProfile.last_name, systemName: "phone")

                        DatePicker(selection: Binding(
                            get: { userProfile.date_of_birth },
                            set: { newValue in
                                userProfile.date_of_birth = newValue
                            }
                        ), in: ...Date(), displayedComponents: .date) {
                            Text("Date of Birth")
                        }
                        .padding(.vertical, 16)

                        Text("Email")
                            .font(.caption)
                        
                        CustomTextField(placeholder: "Email", field: $userProfile.last_name, systemName: "envelope")

                        
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        Task {
                            await updateUserProfile()
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private func updateUserProfile() async {
        do {
            LOG.debug("\(userProfile.latitude)")
            try await manager.updateUserProfile(userProfile: userProfile)
            LOG.info("Profile updated successfully!")
        } catch {
            LOG.error("Error updating profile: \(error.localizedDescription)")
        }
    }
    
    
}

//
//#Preview {
//    ProfileEditingPageView(userProfile: .constant(nil), hasLoadedProfile: .constant(false))
//}
