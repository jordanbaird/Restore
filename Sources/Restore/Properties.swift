//===----------------------------------------------------------------------===//
//
// Properties.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

/// A container for the restorable properties owned by an instance of a
/// ``RestorableObject`` type.
///
/// This type dynamically looks up its members, and is completely type safe. It
/// will not allow invalid values to be accessed, ensuring that only those values
/// that belong to the object associated with an instance will be returned.
@dynamicMemberLookup
public struct Properties<Object: RestorableObject> {
  private let object: Object
  private let properties: [String: Any]
  
  init(_ snapshot: Snapshot<Object>) {
    object = snapshot.object
    properties = snapshot.allProperties.reduce(into: [:]) { $0[$1.0] = $1.1 }
  }
  
  func _member<Value>(withName name: String) -> Value? {
    let property = properties[name]
    if let property = property as? Restorable<Reference<Object>> {
      return property.wrappedValue.originalValue as? Value
    }
    return property as? Value
  }
  
  subscript<Value>(dynamicMember member: String) -> Value? {
    _member(withName: member)
  }
  
  // Including this subscript, but making it unavailable convinces the IDE to
  // show autocomplete suggestions for `Object`. As an additional benefit, it
  // prevents invalid values from being passed to the true subscript, above.
  @available(*, unavailable, message: "specify an Optional return type.")
  subscript<Value>(dynamicMember member: KeyPath<Object, Value>) -> Value {
    fatalError("subscript(dynamicMember:) is unavailable.")
  }
}
