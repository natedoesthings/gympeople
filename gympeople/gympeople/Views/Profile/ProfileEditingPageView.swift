//
//  ProfileEditingPageView.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 11/19/25.
//

import SwiftUI
import MapKit

struct ProfileEditingPageView: View {
    @State var userProfile: UserProfile
    @Environment(\.dismiss) var dismiss
    
    @State private var checkingUsername: Bool = false
    @State private var validUserName: Bool = true
    @State private var showInvalidUsernameAlert: Bool = false
    
    @FocusState private var userNameFieldIsFocused: Bool
    
    let manager = SupabaseManager.shared
    
    var body: some View {
        NavigationView {
            VStack {
                HiddenScrollView {
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
                            .focused($userNameFieldIsFocused)
                            
                            Spacer()
                            
                            if checkingUsername {
                                ProgressView()
                                    .padding(.trailing, 10)
                            } else {
                                // TODO: https://github.com/natedoesthings/gympeople/issues/23
                                Image(systemName: validUserName ? "checkmark.circle.fill" : "x.circle.fill")
                                    .padding(.trailing, 10)
                                    .foregroundStyle(validUserName ? .success : .error)
                            }
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
                        
                        Text("Gym Memberships")
                            .font(.caption)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HiddenScrollView(.horizontal) {
                                HStack {
                                    if !userProfile.gym_memberships.isEmpty {
                                        ForEach(userProfile.gym_memberships, id: \.self) { gym in
                                            Button {
                                                
                                            } label: {
                                                GymTagButton(gymTagType: .gym(gym: gym))
                                            }
                                            
                                        }
                                        
                                        NavigationLink {
                                            GymEditingView(gym_memberships: $userProfile.gym_memberships)
                                        } label: {
                                            GymTagButton(gymTagType: .plus)
                                        }
                                        
                                    } else {
                                        NavigationLink {
                                            GymEditingView(gym_memberships: $userProfile.gym_memberships)
                                        } label: {
                                            GymTagButton(gymTagType: .none)
                                        }
                                    }
                                }
                                .padding(1)
                            }
                        }
                        
                        Text("Phone")
                            .font(.caption)
                        CustomTextField(placeholder: "e.g. 615-555-1234", field: $userProfile.phone_number, systemName: "phone")

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
                        
                        CustomTextField(placeholder: "Email", field: $userProfile.email, systemName: "envelope")

                        
                        
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        if !validUserName {
                            showInvalidUsernameAlert = true
                        } else {
                            Task {
                                await updateUserProfile()
                                dismiss()
                            }
                        }
                    }
                }
            }
            .onChange(of: userNameFieldIsFocused) { _,newValue in
                Task {
                    if newValue { return }
                    
                    checkingUsername = true
                    validUserName = await SupabaseManager.shared.checkUserName(userName: userProfile.user_name) && !userProfile.user_name.isEmpty
                    checkingUsername = false
                }
            }
            .alert(isPresented: $showInvalidUsernameAlert) {
                Alert(
                    title: Text("Username Invalid"),
                    message: Text("The username you have entered was invalid, please try again or dismiss any changes you have made"),
                    primaryButton: .cancel(Text("Go Back")),
                    secondaryButton: .destructive(Text("Continue"), action: { dismiss() })
                )
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
