// AnyEncodable.swift
import Foundation

public struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    public init<T: Encodable>(_ value: T?) {
        _encode = { encoder in
            var container = encoder.singleValueContainer()
            if let value = value {
                try container.encode(value)
            } else {
                try container.encodeNil()
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
