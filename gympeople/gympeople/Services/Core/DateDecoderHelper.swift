//
//  DateDecoderHelper.swift
//  gympeople
//
//  Created by Nathanael Tesfaye on 12/7/25.
//

import Foundation

/// Helper for creating date decoders for Supabase responses
struct DateDecoderHelper {
    /// Creates a JSONDecoder configured for Supabase date formats
    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")

        // Supabase/PostgREST returns timestamps with fractional seconds
        let isoFormatterWithFractional = ISO8601DateFormatter()
        isoFormatterWithFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            // Try ISO8601 with fractional seconds first (Supabase default)
            if let date = isoFormatterWithFractional.date(from: dateString) {
                return date
            }
            // Try standard ISO8601
            if let date = ISO8601DateFormatter().date(from: dateString) {
                return date
            }
            // Try yyyy-MM-dd'T'HH:mm:ssZZZZZ
            if let date = formatter.date(from: dateString) {
                return date
            }
            // Try yyyy-MM-dd (date-only)
            let shortFormatter = DateFormatter()
            shortFormatter.dateFormat = "yyyy-MM-dd"
            if let date = shortFormatter.date(from: dateString) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unrecognized date format: \(dateString)"
            )
        }

        return decoder
    }
}
