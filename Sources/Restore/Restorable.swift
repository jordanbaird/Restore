//===----------------------------------------------------------------------===//
//
// Managed.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

// MARK: - RestorableWrapper

protocol RestorableWrapper: CustomStringConvertible, CustomDebugStringConvertible {
  var key: UInt64 { get }
  var value: Any { get nonmutating set }
}

// MARK: - Restorable

/// A property wrapper type that enables the value it wraps to be included as
/// part of snapshots taken by instances of ``RestorableObject`` types.
@propertyWrapper
public struct Restorable<Value>: RestorableWrapper {
  
  // MARK: - Nested Types
  
  class ManagedState {
    let key = UInt64.random(in: UInt64.min...UInt64.max)
    var value: Value
    init(_ value: Value) {
      self.value = value
    }
  }
  
  /// A state that dictates whether nested instances of ``Restorable`` are
  /// wrapped by their parent instance, or pass their values up into their
  /// parent instance.
  public struct NestedState<T> {
    let rawValue: String
    init(_ rawValue: String = #function) {
      self.rawValue = rawValue
    }
  }
  
  // MARK: - Properties
  
  let state: ManagedState
  
  /// A textual representation of the wrapper.
  public var description: String {
    "\(Self.self)(\(wrappedValue))"
  }
  
  /// A textual representation of the wrapper that is suitable for debugging.
  public var debugDescription: String {
    "\(Self.self)(wrappedValue: \(wrappedValue))"
  }
  
  var key: UInt64 {
    state.key
  }
  
  /// The wrapper, projected.
  ///
  /// You can access this property by prefixing the external wrapped property
  /// with a dollar sign `($)`.
  ///
  /// ```swift
  /// @Restorable var value = "Foo"
  ///
  /// print($value)
  /// // Prints: "Restorable<String>(Foo)"
  /// ```
  public var projectedValue: Self {
    self
  }
  
  /// The wrapped value of the instance.
  public var wrappedValue: Value {
    get { state.value }
    nonmutating set { state.value = newValue }
  }
  
  var value: Any {
    get { wrappedValue }
    nonmutating set {
      if let value = newValue as? Value {
        wrappedValue = value
      }
    }
  }
  
  // MARK: - Initializers
  
  init(state: ManagedState) {
    self.state = state
  }
  
  init(value: Value) {
    self.init(state: .init(value))
  }
  
  /// Creates a wrapper that wraps the given value.
  public init(wrappedValue: Value) {
    self.init(value: wrappedValue)
  }
  
  /// Creates a wrapper that wraps the given value, optionally nesting another
  /// wrapper inside itself.
  ///
  /// If `state` is `nested`, then, if the value is another `Restorable` instance
  /// (i.e. a "nested" `Restorable` instance), the wrapped value of this instance
  /// will assume the value of the nested wrapper's wrapped value, rather than
  /// assuming the value of the wrapper itself.
  ///
  /// ```swift
  /// @Restorable(state: .standard) var value1 = Restorable("Hello")
  /// // value1 is initialized to a value of Restorable("Hello").
  ///
  /// @Restorable(state: .nested) var value2 = Restorable("Hello")
  /// // value2 is initialized to a value of "Hello".
  /// ```
  public init<V>(wrappedValue: V, state: NestedState<V>) {
    if let wrappedValue = wrappedValue as? Self {
      self.init(wrappedValue: wrappedValue.wrappedValue)
    } else {
      self.init(wrappedValue: wrappedValue as! Value)
    }
  }
  
  /// Creates a wrapper with the given state.
  public init<V>(state: NestedState<V>) where Value == V? {
    self.init(wrappedValue: nil)
  }
  
  /// Creates a wrapper that wraps the given value.
  public init(_ value: Value) {
    self.init(wrappedValue: value)
  }
  
  /// Creates a wrapper from the value of another wrapper.
  public init(other: Self) {
    self = other
  }
}

// MARK: - Extensions

extension Restorable.NestedState {
  /// A value that indicates that nested instances of ``Restorable`` will
  /// be wrapped by their parent instance.
  public static var standard: Self { .init() }
}

extension Restorable.NestedState where T == Value? {
  /// A value that indicates that nested instances of ``Restorable`` will
  /// be wrapped by their parent instance.
  public static var standard: Self { .init() }
}

extension Restorable.NestedState where T == Restorable {
  /// A value that indicates that nested instances of ``Restorable`` will
  /// pass their values up into their parent instance.
  public static var nested: Self { .init() }
}

extension Restorable.NestedState where T == Restorable? {
  /// A value that indicates that nested instances of ``Restorable`` will
  /// pass their values up into their parent instance.
  public static var nested: Self { .init() }
}

extension Restorable.NestedState: Equatable { }

extension Restorable.NestedState: Hashable { }
