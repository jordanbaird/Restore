//===----------------------------------------------------------------------===//
//
// Identifier.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

/// A type that identifies a ``RestorableObject`` instance.
public struct Identifier {
  let rawValue: String
  
  init(_rawValue: String) {
    rawValue = _rawValue
  }
  
  init<Object: AnyObject>(for object: Object) {
    self.init(_rawValue: "\(ObjectIdentifier(object))")
  }
  
  /// Creates an identifier with a random value.
  public init() {
    self.init(_rawValue: "\(UInt64.random(in: UInt64.min...UInt64.max))")
  }
}

extension Identifier: Codable { }

extension Identifier: Equatable { }

extension Identifier: Hashable { }
