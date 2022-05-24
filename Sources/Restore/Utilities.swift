//===----------------------------------------------------------------------===//
//
// Utilities.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

extension ObjectIdentifier {
  private class _BackingIdentifier { }
  static func random() -> Self {
    .init(_BackingIdentifier())
  }
}
