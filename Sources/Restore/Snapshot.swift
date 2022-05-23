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
  
  let object: Object
  let storage: [UInt64: (String, Any)]
  
  // MARK: - Initializers
  
  init(for object: Object) {
    self.object = object
    var storage = [UInt64: (String, Any)]()
    for (var name, wrapper) in object.restorableProperties {
      name.removeFirst()
      storage[wrapper.key] = (name, wrapper.value)
    }
    for reference in object.trueReferences {
      storage[.random(in: UInt64.min...UInt64.max)] = (reference.name, reference)
    }
    self.storage = storage
  }
  
  // MARK: - Methods
  
  func restore() {
    for (_, wrapper) in object.restorableProperties {
      if let value = storage[wrapper.key]?.1 {
        wrapper.value = value
      }
    }
    for value in storage.values {
      if let reference = value.1 as? Reference<Object> {
        reference.restore()
      }
    }
  }
  
  func restore<T>(_ keyPath: KeyPath<Object, Restorable<T>>) {
    let property = object[keyPath: keyPath]
    guard
      let wrapper = object.wrappers.first(where: { $0.key == property.key }),
      let value = storage[wrapper.key]?.1
    else {
      assertionFailure("No valid property is stored for key \(property.key).")
      return
    }
    wrapper.value = value
  }
}
