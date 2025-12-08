//
//  R2StorageService.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import Foundation
import UIKit

enum R2UploadError: Error {
    case invalidImageData
    case uploadFailed(String)
    case invalidURL
}

class R2StorageService {
    static let shared = R2StorageService()
    
    private let workerEndpoint: String
    private let uploadSecret: String
    
    private init() {
        self.workerEndpoint = Env.r2ApiEndpoint
        self.uploadSecret = Env.r2UploadSecret
    }
    
    /// Upload a membership verification image to R2 via Cloudflare Worker
    /// - Parameters:
    ///   - image: The image to upload
    ///   - userId: The user's ID
    ///   - gymId: The gym's ID
    /// - Returns: The public URL of the uploaded file
    func uploadVerificationImage(image: UIImage, userId: UUID, gymId: UUID) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw R2UploadError.invalidImageData
        }
        
        let filename = "verification_\(userId.uuidString)_\(gymId.uuidString)_\(Date().timeIntervalSince1970).jpg"
        
        return try await uploadViaWorker(imageData, filename: filename, contentType: "image/jpeg")
    }
    
    /// Upload a membership verification document to R2 via Cloudflare Worker
    /// - Parameters:
    ///   - data: The file data to upload
    ///   - fileName: The original filename
    ///   - userId: The user's ID
    ///   - gymId: The gym's ID
    /// - Returns: The public URL of the uploaded file
    func uploadVerificationDocument(data: Data, fileName: String, userId: UUID, gymId: UUID) async throws -> String {
        // Determine content type from file extension
        let fileExtension = (fileName as NSString).pathExtension.lowercased()
        let contentType: String
        let finalExtension: String
        
        switch fileExtension {
        case "pdf":
            contentType = "application/pdf"
            finalExtension = "pdf"
        case "jpg", "jpeg":
            contentType = "image/jpeg"
            finalExtension = "jpg"
        case "png":
            contentType = "image/png"
            finalExtension = "png"
        case "heic":
            contentType = "image/heic"
            finalExtension = "heic"
        default:
            contentType = "application/octet-stream"
            finalExtension = fileExtension
        }
        
        let filename = "verification_\(userId.uuidString)_\(gymId.uuidString)_\(Date().timeIntervalSince1970).\(finalExtension)"
        
        return try await uploadViaWorker(data, filename: filename, contentType: contentType)
    }
    
    /// Upload via Cloudflare Worker (simple multipart/form-data)
    private func uploadViaWorker(_ data: Data, filename: String, contentType: String) async throws -> String {
        guard let url = URL(string: workerEndpoint) else {
            throw R2UploadError.invalidURL
        }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(uploadSecret)", forHTTPHeaderField: "Authorization")
        
        // Create multipart body
        var body = Data()
        
        // Add filename field
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"filename\"\r\n\r\n".data(using: .utf8)!)
        body.append("membership-verifications/\(filename)\r\n".data(using: .utf8)!)
        
        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        LOG.info("Uploading \(filename) to worker: \(workerEndpoint)")
        LOG.info("File size: \(data.count) bytes")
        
        do {
            let (responseData, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw R2UploadError.uploadFailed("Invalid response")
            }
            
            LOG.info("Response status: \(httpResponse.statusCode)")
            
            if let responseString = String(data: responseData, encoding: .utf8) {
                LOG.info("Response: \(responseString)")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: responseData, encoding: .utf8) ?? "Unknown error"
                LOG.error("Upload failed: \(errorMessage)")
                throw R2UploadError.uploadFailed("Status \(httpResponse.statusCode): \(errorMessage)")
            }
            
            // Construct the public URL
            let publicUrl = "\(workerEndpoint)/membership-verifications/\(filename)"
            LOG.info("Upload successful: \(publicUrl)")
            return publicUrl
        } catch let error as R2UploadError {
            throw error
        } catch {
            LOG.error("Upload failed: \(error)")
            throw R2UploadError.uploadFailed(error.localizedDescription)
        }
    }
}
