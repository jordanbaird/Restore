//===----------------------------------------------------------------------===//
//
// Identifier.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

/// A type that identifies a ``RestorableObject`` instance.
///
/// On creation, an instance of this type is set to a random value. When you
/// create a property with a value of this type, you should make it a `let`
/// constant in order to be sure that the value consistently functions as a
/// unique identifier.
public struct Identifier {
  let rawValue: String
  
  init(_raw: Any) {
    rawValue = "\(_raw)"
  }
  
  init<Object: AnyObject>(for object: Object) {
    self.init(_raw: ObjectIdentifier(object))
  }
  
  /// Creates an identifier with a random value.
  ///
  /// When creating a value using this initializer, it should be made a `let`
  /// constant in order to be sure that the value consistently functions as a
  /// unique identifier.
  init() {
    self.init(_raw: UInt64.random())
  }
}

// MARK: - Extensions

extension Identifier: Codable { }

extension Identifier: Equatable { }

extension Identifier: Hashable { }
