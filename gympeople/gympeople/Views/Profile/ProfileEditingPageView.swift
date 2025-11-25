//
//  ProfileEditingPageView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/19/25.
//

import SwiftUI

struct ProfileEditingPageView: View {
    @Binding var userProfile: UserProfile
    @Binding var hasLoadedProfile: Bool
    @Environment(\.dismiss) var dismiss
    
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
                        HStack {
                            Image(systemName: "text.book.closed")
                                .foregroundColor(.gray)
                                .padding(.leading, 10)
                            
                            TextField("Bio", text: Binding(
                                get: { userProfile.biography ?? "" },
                                set: { newValue in
                                    userProfile.biography = newValue
                                }
                            ))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.vertical, 12)
                        }
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 2)
                        )
                        
                        Text("First Name")
                            .font(.caption)
                        HStack {
                            Image(systemName: "person")
                                .foregroundColor(.gray)
                                .padding(.leading, 10)
                            
                            TextField("First Name", text: $userProfile.first_name)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.vertical, 12)
                        }
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 2)
                        )
                        
                        Text("Last Name")
                            .font(.caption)
                        HStack {
                            Image(systemName: "person.text.rectangle")
                                .foregroundColor(.gray)
                                .padding(.leading, 10)
                            
                            TextField("Last Name", text: $userProfile.last_name)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.vertical, 12)
                        }
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 2)
                        )
                        
                        Text("Location")
                            .font(.caption)
                        HStack {
                            Image(systemName: "mappin")
                                .foregroundColor(.gray)
                                .padding(.leading, 10)
                            
                            TextField("Location", text: Binding(
                                get: { userProfile.location ?? "" },
                                set: { newValue in
                                    userProfile.location = newValue
                                }
                            ))
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.vertical, 12)
                        }
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 2)
                        )
                        
                        Text("Phone")
                            .font(.caption)
                        HStack {
                            Image(systemName: "phone")
                                .foregroundColor(.gray)
                                .padding(.leading, 10)
                            
                            TextField("e.g. 615-555-1234", text: $userProfile.phone_number)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.vertical, 12)
                        }
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 2)
                        )

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
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                                .padding(.leading, 10)
                            
                            TextField("Email", text: $userProfile.email)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding(.vertical, 12)
                            .disabled(true)
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 2)
                        )
                        
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
                            hasLoadedProfile = false
                            dismiss()
                        }
                        
                    }
                }
            }
        }
    }
    
    private func updateUserProfile() async {
        do {
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
