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
  
  // MARK: Properties
  
  let rawValue: String
  
  // MARK: - Initializers
  
  init(_rawValue: String) {
    rawValue = _rawValue
  }
  
  init<Object: AnyObject>(for object: Object) {
    self.init(_rawValue: "\(ObjectIdentifier(object))")
  }
  
  /// Creates an identifier with a random value.
  ///
  /// When creating a value using this initializer, it should be made a `let`
  /// constant in order to be sure that the value consistently functions as a
  /// unique identifier.
  public init() {
    self.init(_rawValue: "\(UInt64.random(in: UInt64.min...UInt64.max))")
  }
}

// MARK: - Extensions

extension Identifier: Codable { }

extension Identifier: Equatable { }

extension Identifier: Hashable { }
