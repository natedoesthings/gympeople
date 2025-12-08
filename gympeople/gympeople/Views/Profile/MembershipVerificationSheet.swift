//
//  MembershipVerificationSheet.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import SwiftUI
import Supabase

// MARK: - Membership Verification Sheet

struct MembershipVerificationSheet: View {
    @Environment(\.dismiss) var dismiss
    let gym: Gym
    @State private var selectedImage: UIImage?
    @State private var selectedDocumentData: Data?
    @State private var selectedDocumentFileName: String?
    @State private var showImagePicker = false
    @State private var showDocumentPicker = false
    @State private var isSubmitting = false
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Gym Header
                    VStack(spacing: 12) {
                        Image(systemName: "dumbbell.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.brandOrange)
                            .frame(width: 80, height: 80)
                            .background(
                                Circle()
                                    .fill(Color.brandOrange.opacity(0.15))
                            )
                        
                        Text(gym.name ?? "Unknown Gym")
                            .font(.title2)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        if let address = gym.address {
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.caption)
                                Text(address)
                                    .font(.subheadline)
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.top, 8)
                    
                    Divider()
                    
                    // Status Section
                    VStack(spacing: 16) {
                        HStack {
                            Text("Verification Status")
                                .font(.headline)
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: gym.verification_status!.icon)
                                .font(.title3)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(gym.verification_status!.name)
                                    .font(.headline)
                                
                                Text(gym.verification_status!.displayText)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                        }
                        .foregroundStyle(gym.verification_status!.color)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(gym.verification_status!.color.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(gym.verification_status!.color.opacity(0.3), lineWidth: 1)
                        )
                    }
                    
                    // Verification Content
                    if gym.verification_status == .unverified {
                        UnverifiedContent(
                            selectedImage: $selectedImage,
                            selectedDocumentData: $selectedDocumentData,
                            selectedDocumentFileName: $selectedDocumentFileName,
                            showImagePicker: $showImagePicker,
                            showDocumentPicker: $showDocumentPicker,
                            isSubmitting: isSubmitting,
                            onSubmit: submitVerification
                        )
                    } else if gym.verification_status == .pending {
                        PendingContent()
                    } else {
                        VerifiedContent()
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Membership Verification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(documentData: $selectedDocumentData, fileName: $selectedDocumentFileName)
            }
            .alert("Verification Submitted", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your verification request has been submitted. We'll review it within 1-2 business days.")
            }
        }
    }
    
    // MARK: - Actions
    
    private func submitVerification() {
        guard let currentUserId = SupabaseManager.shared.client.auth.currentUser?.id else {
            LOG.error("No current user ID")
            return
        }
        
        isSubmitting = true
        
        Task {
            do {
                let fileURL: String
                
                // Upload based on what we have
                if let image = selectedImage {
                    fileURL = try await R2StorageService.shared.uploadVerificationImage(
                        image: image,
                        userId: currentUserId,
                        gymId: gym.id
                    )
                } else if let documentData = selectedDocumentData, let fileName = selectedDocumentFileName {
                    fileURL = try await R2StorageService.shared.uploadVerificationDocument(
                        data: documentData,
                        fileName: fileName,
                        userId: currentUserId,
                        gymId: gym.id
                    )
                } else {
                    LOG.error("No file to upload")
                    await MainActor.run {
                        isSubmitting = false
                    }
                    return
                }
                
                LOG.info("Uploaded verification document: \(fileURL)")
                
                // Update membership status to 'pending' in database
                try await SupabaseManager.shared.updateMembershipVerification(
                    gymId: gym.id,
                    documentUrl: fileURL
                )
                
                await MainActor.run {
                    isSubmitting = false
                    showSuccessAlert = true
                }
            } catch {
                LOG.error("Failed to upload verification: \(error.localizedDescription)")
                await MainActor.run {
                    isSubmitting = false
                    // TODO: Show error alert to user
                }
            }
        }
    }
}

// MARK: - Unverified Content View

struct UnverifiedContent: View {
    @Binding var selectedImage: UIImage?
    @Binding var selectedDocumentData: Data?
    @Binding var selectedDocumentFileName: String?
    @Binding var showImagePicker: Bool
    @Binding var showDocumentPicker: Bool
    let isSubmitting: Bool
    let onSubmit: () -> Void
    
    private var hasUpload: Bool {
        selectedImage != nil || selectedDocumentData != nil
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Divider()
            
            VStack(spacing: 16) {
                HStack {
                    Text("Submit Verification")
                        .font(.headline)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("To verify your membership, please upload one of the following:")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        bulletPoint("Photo of your gym membership card")
                        bulletPoint("Screenshot of membership confirmation email")
                        bulletPoint("Photo of your gym key fob or access card")
                        bulletPoint("Any official document showing your membership")
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
            
            VStack(spacing: 12) {
                if let image = selectedImage {
                    VStack(spacing: 12) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Button {
                            selectedImage = nil
                        } label: {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("Remove Image")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.red)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                } else if let documentData = selectedDocumentData, let fileName = selectedDocumentFileName {
                    VStack(spacing: 12) {
                        VStack(spacing: 8) {
                            Image(systemName: "doc.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.blue)
                            
                            Text(fileName)
                                .font(.headline)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                            
                            Text("\(ByteCountFormatter.string(fromByteCount: Int64(documentData.count), countStyle: .file))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        
                        Button {
                            selectedDocumentData = nil
                            selectedDocumentFileName = nil
                        } label: {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("Remove Document")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.red)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                } else {
                    VStack(spacing: 12) {
                        Button {
                            showImagePicker = true
                        } label: {
                            uploadButtonContent(
                                icon: "photo.on.rectangle",
                                title: "Upload from Photos",
                                subtitle: "Choose an image from your library"
                            )
                        }
                        .foregroundStyle(.primary)
                        
                        Button {
                            showDocumentPicker = true
                        } label: {
                            uploadButtonContent(
                                icon: "doc.on.doc",
                                title: "Upload Document",
                                subtitle: "Choose a PDF or other document"
                            )
                        }
                        .foregroundStyle(.primary)
                    }
                }
            }
            
            Button {
                onSubmit()
            } label: {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Submit for Verification")
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(hasUpload ? Color.brandOrange : Color.secondary)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(!hasUpload || isSubmitting)
        }
    }
    
    @ViewBuilder
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private func uploadButtonContent(icon: String, title: String, subtitle: String) -> some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
}

// MARK: - Pending Content View

struct PendingContent: View {
    var body: some View {
        VStack(spacing: 20) {
            Divider()
            
            VStack(spacing: 16) {
                Image(systemName: "clock.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.orange)
                
                Text("Under Review")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("We're reviewing your verification request. This usually takes 1-2 business days. You'll receive a notification once it's complete.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.vertical, 32)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("What happens next?")
                        .font(.headline)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    timelineStep(number: 1, text: "Our team reviews your submission")
                    timelineStep(number: 2, text: "We verify with the gym if needed")
                    timelineStep(number: 3, text: "You receive confirmation")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
    }
    
    @ViewBuilder
    private func timelineStep(number: Int, text: String) -> some View {
        HStack(spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.orange))
            
            Text(text)
                .font(.subheadline)
        }
    }
}

// MARK: - Verified Content View

struct VerifiedContent: View {
    var body: some View {
        VStack(spacing: 20) {
            Divider()
            
            VStack(spacing: 16) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.green)
                
                Text("Verified!")
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text("Your membership has been verified. You now have full access to this gym's community and features.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.vertical, 32)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Member Benefits")
                        .font(.headline)
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    benefitRow(icon: "person.2.fill", text: "Connect with other members")
                    benefitRow(icon: "bubble.left.and.bubble.right.fill", text: "Join gym discussions")
                    benefitRow(icon: "bell.fill", text: "Get gym updates and events")
                    benefitRow(icon: "chart.line.uptrend.xyaxis", text: "Track your gym activity")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.green.opacity(0.1))
            )
        }
    }
    
    @ViewBuilder
    private func benefitRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.green)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
        }
    }
}
