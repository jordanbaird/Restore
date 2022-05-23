//===----------------------------------------------------------------------===//
//
// ReferenceBuilder.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

// MARK: - AnyReference

/// A type-erased reference object that references an unwrapped property of a
/// ``RestorableObject`` type.
///
/// This type contains an associated type called ``Object``. The ``Object`` type
/// will be a type that conforms to ``RestorableObject``. When you provide instances
/// of this type to an instance of ``Object``'s `references` property, they will be
/// wrapped in ``Restorable`` attributes and stored, just as if they were marked with
/// the attribute themselves. This can be useful when you need to, for example,
/// include computed properties in snapshots, as computed properties do not support
/// property wrappers.
public protocol AnyReference {
  /// The ``RestorableObject`` type whose properties are referenced by this type.
  associatedtype Object: RestorableObject
}

// MARK: - Reference

/// A type that references an unwrapped property of a ``RestorableObject`` type.
///
/// When you provide instances of this type to a restorable object's `references`
/// property, they will be wrapped in ``Restorable`` attributes and stored, just
/// as if they were marked with the attribute themselves. This can be useful when
/// you need to, for example, include computed properties in snapshots, as
/// computed properties do not support property wrappers.
public struct Reference<Object: RestorableObject>: AnyReference {
  
  // MARK: - Properties
  
  let name: String
  let originalValue: Any
  let restore: () -> Void
  
  // MARK: - Initializers
  
  init<Value>(
    object: Object,
    name: String,
    originalValue: Value,
    keyPath: ReferenceWritableKeyPath<Object, Value>
  ) {
    self.name = name
    self.originalValue = originalValue
    restore = {
      object[keyPath: keyPath] = originalValue
    }
  }
  
  /// Creates a reference from the given owner, name and key path.
  /// - Important: The `name` parameter _must_ have the same name as the property you
  /// are referencing, or the value will not be stored.
  public init<Value>(
    object: Object,
    name: String,
    keyPath: ReferenceWritableKeyPath<Object, Value>
  ) {
    self.init(
      object: object,
      name: name,
      originalValue: object[keyPath: keyPath],
      keyPath: keyPath)
  }
}

// MARK: - _ReferenceBuilder

@resultBuilder
public struct _ReferenceBuilder<Object: RestorableObject> {
  public static func buildBlock(_ components: Reference<Object>...) -> [Reference<Object>] {
    components
  }
}
