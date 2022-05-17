//===----------------------------------------------------------------------===//
//
// Restorable.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

var storage = [Identifier: [RestorationKey: AnySnapshot]]()

/// A type that can be stored and restored from a snapshot.
///
/// Use ``takeSnapshot(withKey:)`` to take a snapshot, and ``restore(withKey:)``
/// to restore all the values of an instance that are wrapped in ``Restorable``
/// attributes to the values they held when the snapshot was taken.
public protocol RestorableObject where ReferenceType.Object == Self {
  /// The type of reference object associated with the current type.
  associatedtype ReferenceType: AnyReference = Reference<Self>
  
  /// An identifier for the instance.
  ///
  /// For reference types, such as classes, this property is synthesized automatically.
  /// However, for value types, such as structs, this property must be implemented. It
  /// should be a `let` constant to ensure that it functions as a unique, consistent
  /// identifier for the instance.
  var restorableObjectIdentifier: Identifier { get }
  
  /// An array of references to properties that cannot be wrapped with ``Restorable`` wrappers.
  ///
  /// These properties will usually be computed properties, as they do not support property
  /// wrappers. If you provide them here, they will be stored when snapshots are taken, and
  /// restored when instances of this type are restored.
  ///
  /// ```swift
  /// class SomeObject: RestorableObject {
  ///     @Restorable var value1: String
  ///     @Restorable var value2: Int?
  ///
  ///     var _value3 = false // Backing property.
  ///
  ///     var value3: Bool { _value3 } // Cannot be wrapped.
  ///
  ///     var references: [Reference<SomeObject>] {
  ///         Reference(owner: self, keyPath: \.value3)
  ///     }
  /// }
  /// ```
  @_ReferenceBuilder<Self> var references: [ReferenceType] { get }
}

extension RestorableObject where Self: AnyObject {
  var restorableObjectIdentifier: Identifier {
    .init(for: self)
  }
}

extension RestorableObject {
  
  // MARK: - Instance Properties
  
  public var references: [ReferenceType] { [] }
  
  var trueReferences: [Reference<Self>] {
    references as? [Reference<Self>] ?? []
  }
  
  var snapshots: [RestorationKey: AnySnapshot] {
    get {
      if let storage = storage[restorableObjectIdentifier] {
        return storage
      } else {
        storage[restorableObjectIdentifier] = [:]
        return [:]
      }
    }
    nonmutating set {
      storage[restorableObjectIdentifier] = newValue
    }
  }
  
  var restorableProperties: [String: RestorableWrapper] {
    Mirror(reflecting: self).children.reduce(into: [:]) {
      if
        let label = $1.label,
        let value = $1.value as? RestorableWrapper
      {
        $0[label] = value
      }
    }
  }
  
  var wrappers: [RestorableWrapper] {
    .init(restorableProperties.values)
  }
  
  // MARK: - Methods
  
  /// Takes and returns a snapshot of all the ``Restorable``-wrapped properties
  /// of an instance.
  public func takeSnapshot() -> Snapshot<Self> {
    .init(for: self)
  }
  
  /// Takes a snapshot of all the ``Restorable``-wrapped properties of an instance
  /// and stores their values under the given key.
  @discardableResult
  public func takeSnapshot(withKey key: RestorationKey) -> Snapshot<Self> {
    let snapshot = takeSnapshot()
    snapshots[key] = snapshot
    return snapshot
  }
  
  /// Restores all the ``Restorable``-wrapped properties of an instance to the
  /// values they contained when the given snapshot was taken.
  public func restore(from snapshot: Snapshot<Self>) throws {
    try validate(snapshot: snapshot)
    for (_, wrapper) in restorableProperties {
      if let value = snapshot.getSingleValue(forWrapper: wrapper) {
        wrapper.value = value
      }
    }
    for property in snapshot.allProperties {
      if let property = property.1 as? Restorable<Reference<Self>> {
        property.wrappedValue.restore()
      }
    }
  }
  
  /// Restores all the ``Restorable``-wrapped properties of an instance to the
  /// values they contained when the snapshot with the given key was taken.
  public func restore(withKey key: RestorationKey) throws {
    guard let snapshot = snapshots[key] as? Snapshot<Self> else {
      throw RestorationError.noSnapshot(forKey: key)
    }
    try restore(from: snapshot)
  }
  
  /// Restores the property at the given keypath to the value that it contained
  /// when the given snapshot was taken.
  ///
  /// Note that you must access the underlying ``Restorable`` property wrapper,
  /// rather than the property itself. To do so, prefix the name of the property
  /// with a dollar sign ($).
  ///
  /// ```swift
  /// try someObject.restore(\.$someValue, from: someSnapshot)
  /// ```
  public func restore<T>(_ property: KeyPath<Self, Restorable<T>>, from snapshot: Snapshot<Self>) throws {
    try validate(snapshot: snapshot)
    let property = self[keyPath: property]
    guard
      let wrapper = wrappers.first(where: { $0.key == property.key }),
      let value = snapshot.getSingleValue(forWrapper: wrapper)
    else {
      throw RestorationError.unknownProperty
    }
    wrapper.value = value
  }
  
  /// Restores the property at the given keypath to the value that it contained
  /// when the snapshot with the given key was taken.
  ///
  /// Note that you must access the underlying ``Restorable`` property wrapper,
  /// rather than the property itself. To do so, prefix the name of the property
  /// with a dollar sign ($).
  ///
  /// ```swift
  /// try someObject.restore(\.$someValue, withKey: "SomeKey")
  /// ```
  public func restore<T>(_ property: KeyPath<Self, Restorable<T>>, withKey key: RestorationKey) throws {
    guard let snapshot = snapshots[key] as? Snapshot<Self> else {
      throw RestorationError.noSnapshot(forKey: key)
    }
    try restore(property, from: snapshot)
  }
  
  /// Returns the properties contained by the given snapshot.
  public func properties(of snapshot: Snapshot<Self>) throws -> Properties<Self> {
    try validate(snapshot: snapshot)
    return .init(snapshot)
  }
  
  /// Returns the properties contained by the snapshot with the given key.
  public func properties(withKey key: RestorationKey) throws -> Properties<Self> {
    guard let snapshot = snapshots[key] as? Snapshot<Self> else {
      throw RestorationError.noSnapshot(forKey: key)
    }
    return try properties(of: snapshot)
  }
  
  /// Removes the snapshot with the given key.
  public func removeSnapshot(withKey key: RestorationKey) {
    snapshots.removeValue(forKey: key)
  }
  
  /// Removes all snapshots stored by the instance.
  public func removeLocalSnapshots() {
    snapshots.removeAll()
  }
  
  func validate(snapshot: Snapshot<Self>) throws {
    try snapshot.validate(properties: restorableProperties)
  }
}
