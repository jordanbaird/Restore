//
// Utilities.swift
// Restore
//

extension UInt64 {
    static func random() -> Self {
        .random(in: Self.min...Self.max)
    }
}

extension ObjectIdentifier {
    private class _BackingIdentifier { }
    static func random() -> Self {
        .init(_BackingIdentifier())
    }
}
