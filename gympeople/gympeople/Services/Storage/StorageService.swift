//
//  StorageService.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import Foundation
import Supabase
import UIKit

protocol StorageServiceProtocol {
    func uploadProfilePicture(_ image: UIImage) async throws
}

class StorageService: StorageServiceProtocol {
    private let client: SupabaseClient
    private let bucket = "profile_pictures"
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    func uploadProfilePicture(_ image: UIImage) async throws {
        LOG.info("Updating Profile Picture...")
        
        guard let userID = client.auth.currentUser?.id else {
            throw AppError.unauthorized
        }

        // Try to clean up any existing profile picture before uploading a new one
        if let currentURLString = try await getCurrentProfilePictureURL(),
           let path = storagePath(fromPublicURL: currentURLString, bucket: bucket) {
            do {
                try await client.storage
                    .from(bucket)
                    .remove(paths: [path])
                LOG.debug("Removed old profile picture at path: \(path)")
            } catch {
                LOG.error("Failed to remove old profile picture: \(error)")
            }
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw AppError.validationFailed(reason: "Failed to convert image to JPEG")
        }

        let timestamp = Int(Date().timeIntervalSince1970)
        let fileName = "\(userID.uuidString)_\(timestamp).jpg"

        do {
            // Upload to storage
            try await client.storage
                .from(bucket)
                .upload(fileName, data: imageData, options: FileOptions(contentType: "image/jpeg", upsert: true))
            
            // Get public URL
            let publicURL = try client.storage
                .from(bucket)
                .getPublicURL(path: fileName)
            
            // Update profile with new URL
            try await client
                .from("user_profiles")
                .update(["pfp_url": AnyEncodable(publicURL.absoluteString)])
                .eq("id", value: userID)
                .execute()
            
            LOG.info("Profile Picture Updated!")
        } catch {
            LOG.error("Error uploading profile picture: \(error)")
            throw SupabaseErrorMapper.map(error)
        }
    }
    
    // MARK: - Private Helpers
    
    private func getCurrentProfilePictureURL() async throws -> String? {
        guard let userID = client.auth.currentUser?.id else {
            return nil
        }
        
        struct ProfilePictureResponse: Codable {
            let pfp_url: String?
        }
        
        do {
            let response = try await client
                .from("user_profiles")
                .select("pfp_url")
                .eq("id", value: userID)
                .single()
                .execute()
            
            let decoder = JSONDecoder()
            let profile = try decoder.decode(ProfilePictureResponse.self, from: response.data)
            return profile.pfp_url
        } catch {
            return nil
        }
    }
    
    private func storagePath(fromPublicURL urlString: String, bucket: String) -> String? {
        guard let url = URL(string: urlString) else { return nil }
        let components = url.pathComponents
        guard let bucketIndex = components.firstIndex(of: bucket),
              bucketIndex + 1 < components.count else { return nil }
        let pathComponents = components[(bucketIndex + 1)...]
        let path = pathComponents.joined(separator: "/")
        return path.isEmpty ? nil : path
    }
}
