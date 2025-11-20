//
//  ProfileEditingPageView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/19/25.
//

import SwiftUI

struct ProfileEditingPageView: View {
    @Binding var userProfile: UserProfile?
    @Binding var hasLoadedProfile: Bool
    @Environment(\.dismiss) var dismiss
    
    let manager = SupabaseManager.shared
//    @State private var savingProfile: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                if userProfile != nil {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Username")
                                .font(.caption)
                            HStack {
                                Text("@")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 10)
                                
                                TextField("Username", text: Binding(
                                    get: { userProfile?.user_name ?? "" },
                                    set: { newValue in
                                        userProfile?.user_name = newValue
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
                            
                            Text("Bio")
                                .font(.caption)
                            HStack {
                                Image(systemName: "text.book.closed")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 10)
                                
                                TextField("Bio", text: Binding(
                                    get: { userProfile?.biography ?? "" },
                                    set: { newValue in
                                        userProfile?.biography = newValue
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
                                
                                TextField("First Name", text: Binding(
                                    get: { userProfile?.first_name ?? "" },
                                    set: { newValue in
                                        userProfile?.first_name = newValue
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
                            
                            Text("Last Name")
                                .font(.caption)
                            HStack {
                                Image(systemName: "person.text.rectangle")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 10)
                                
                                TextField("Last Name", text: Binding(
                                    get: { userProfile?.last_name ?? "" },
                                    set: { newValue in
                                        userProfile?.last_name = newValue
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
                            
                            Text("Location")
                                .font(.caption)
                            HStack {
                                Image(systemName: "mappin")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 10)
                                
                                TextField("Location", text: Binding(
                                    get: { userProfile?.location ?? "" },
                                    set: { newValue in
                                        userProfile?.location = newValue
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
                                
                                TextField("e.g. 615-555-1234", text: Binding(
                                    get: { userProfile?.phone_number ?? "" },
                                    set: { newValue in
                                        userProfile?.phone_number = newValue
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
    
                            DatePicker(selection: Binding(
                                get: { userProfile?.date_of_birth ?? Date() },
                                set: { newValue in
                                    userProfile?.date_of_birth = newValue
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
                                
                                TextField("Email", text: Binding(
                                    get: { userProfile?.email ?? "" },
                                    set: { newValue in
                                        userProfile?.email = newValue
                                    }
                                ))
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
                } else {
                    Text("Error displaying profile information.")
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
            if let userProfile = userProfile {
                try await manager.updateUserProfile(userProfile: userProfile)
                LOG.info("Profile updated successfully!")
            } else {
                LOG.info("Profile not found. Try again.")
            }
        } catch {
            LOG.error("Error updating profile: \(error.localizedDescription)")
        }
    }
}

//
#Preview {
    ProfileEditingPageView(userProfile: .constant(nil), hasLoadedProfile: .constant(false))
}
