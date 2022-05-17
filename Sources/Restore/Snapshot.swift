//===----------------------------------------------------------------------===//
//
// Snapshot.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

protocol AnySnapshot { }

/// A type that holds the restorable properties of an instance of a ``RestorableObject`` type.
///
/// A value of this type is returned from ``RestorableObject/takeSnapshot()``. You can then pass
/// it into ``RestorableObject/restore(from:)`` to restore the state of the object to what it was
/// when the snapshot was taken.
public struct Snapshot<Object: RestorableObject>: AnySnapshot {
  
  // MARK: - Properties
  
  private var storage = [UInt64: (String, Any)]()
  
  var allProperties: [(String, Any)] {
    .init(storage.values)
  }
  
  // MARK: - Initializers
  
  init(for object: Object) {
    for (var name, wrapper) in object.restorableProperties {
      name.removeFirst()
      storage[wrapper.key] = (name, wrapper.value)
    }
    for reference in object.trueReferences {
      let wrapper = Restorable(reference: reference)
      storage[wrapper.key] = (reference.name, wrapper)
    }
  }
  
  // MARK: - Methods
  
  func getSingleValue(forWrapper wrapper: RestorableWrapper) -> Any? {
    storage[wrapper.key]?.1
  }
  
  func validate(properties: [String: RestorableWrapper]) throws {
    let invalidKeys: [String] = properties.compactMap {
      let wrapper = $0.value
      if storage[wrapper.key] == nil {
        var key = $0.key
        key.removeFirst()
        return key
      }
      return nil
    }
    guard invalidKeys.isEmpty else {
      throw RestorationError.noValues(forProperies: invalidKeys)
    }
  }
}
