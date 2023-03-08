//===----------------------------------------------------------------------===//
//
// Utilities.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

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
