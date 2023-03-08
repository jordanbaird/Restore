//
// RestorationKey.swift
// Restore
//

/// A type that is used as a key to store values in a snapshot.
///
/// This type can be initialized as a string literal, which is preferred.
public struct RestorationKey {

    // MARK: - Properties

    /// The raw value of the key.
    public let rawValue: String

    // MARK: - Initializers

    /// Creates a key with the given raw value.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a key with the given raw value.
    public init(_ rawValue: String) {
        self.init(rawValue: rawValue)
    }
}

// MARK: Extensions

extension RestorationKey: ExpressibleByStringInterpolation {
    /// Creates a key with a string literal.
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

extension RestorationKey: Codable { }

extension RestorationKey: Equatable { }

extension RestorationKey: Hashable { }
