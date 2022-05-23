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
  let name: String
  let originalValue: Any
  let owner: Object
  let restore: () -> Void
  
  init<Value>(
    owner: Object,
    name: String,
    originalValue: Any,
    keyPath: ReferenceWritableKeyPath<Object, Value>
  ) {
    self.name = name
    self.originalValue = originalValue
    self.owner = owner
    restore = {
      guard let originalValue = originalValue as? Value else {
        assertionFailure("Value is not of type \(Value.self). Cannot restore.")
        return
      }
      owner[keyPath: keyPath] = originalValue
    }
  }
  
  /// Creates a reference from the given owner and key path.
  public init<Value>(
    owner: Object,
    name: String,
    keyPath: ReferenceWritableKeyPath<Object, Value>
  ) {
    self.init(
      owner: owner,
      name: name,
      originalValue: owner[keyPath: keyPath],
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
