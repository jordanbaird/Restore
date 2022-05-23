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
  private let properties: [String: Any]
  
  init(_ snapshot: Snapshot<Object>) {
    properties = snapshot.allProperties.reduce(into: [:]) {
      $0[$1.0] = $1.1
    }
    print(properties)
  }
  
  /// Retrieves the property with the given label, assuming one exists as a member of the object.
  public func property<T>(withLabel label: String) -> T? {
    let property = properties[label]
    if let property = property as? Restorable<Reference<Object>> {
      return property.wrappedValue.originalValue as? T
    }
    return property as? T
  }
  
  /// Retrieves the property with the given label, assuming one exists as a member of the object.
  public subscript<T>(label: String) -> T? {
    property(withLabel: label)
  }
  
  /// Dynamically retrieves the property with the given label, assuming one exists as a member of
  /// the object.
  public subscript<T>(dynamicMember member: String) -> T? {
    property(withLabel: member)
  }
}
