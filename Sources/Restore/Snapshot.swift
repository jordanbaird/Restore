//
// Snapshot.swift
// Restore
//

protocol AnySnapshot { }

/// A type that holds the restorable properties of an instance of a ``RestorableObject`` type.
///
/// A value of this type is returned from ``RestorableObject/takeSnapshot()``. You can then pass
/// it into ``RestorableObject/restore(from:)`` to restore the state of the object to what it was
/// when the snapshot was taken.
public struct Snapshot<Object: RestorableObject>: AnySnapshot {

    // MARK: - Properties

    let object: Object
    let storage: [ObjectIdentifier: (String, Any)]

    // MARK: - Initializers

    init(for object: Object) {
        self.object = object
        var storage = [ObjectIdentifier: (String, Any)]()
        for (var name, wrapper) in object.restorableProperties {
            name.removeFirst()
            storage[wrapper.identifier] = (name, wrapper.value)
        }
        for reference in object.trueReferences {
            storage[.random()] = (reference.name, reference)
        }
        self.storage = storage
    }

    // MARK: - Methods

    func restore() {
        for (_, wrapper) in object.restorableProperties {
            if let value = storage[wrapper.identifier]?.1 {
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
            let wrapper = object.wrappers.first(where: { $0.identifier == property.identifier }),
            let value = storage[wrapper.identifier]?.1
        else {
            assertionFailure("No valid property is stored for key \(property.identifier).")
            return
        }
        wrapper.value = value
    }
}
