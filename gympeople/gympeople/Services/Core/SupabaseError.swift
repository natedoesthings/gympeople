//
//  SupabaseError.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import Foundation
import Supabase

/// Maps Supabase errors to AppError
struct SupabaseErrorMapper {
    static func map(_ error: Error) -> AppError {
        // Supabase Swift uses PostgrestError / URLError / DecodingError
        if let pg = error as? PostgrestError {
            switch pg.code {
            case "23505": return .conflict                          // unique violation
            case "23503": return .validationFailed(reason: "Missing related item")
            case "23514": return .validationFailed(reason: "Input violates constraint")
            case "42501": return .unauthorized
            default:       return .unexpected
            }
        } else if let urlErr = error as? URLError {
            switch urlErr.code {
            case .notConnectedToInternet, .timedOut: return .networkUnavailable
            default: return .unexpected
            }
        } else if let httpErr = error as? HTTPError {
            switch httpErr.response.statusCode {
            case 401, 403: return .unauthorized
            case 404: return .notFound
            case 500...599: return .serverError
            default: return .unexpected
            }
        } else if error is DecodingError {
            return .unexpected
        }

        return .unexpected
    }
}
