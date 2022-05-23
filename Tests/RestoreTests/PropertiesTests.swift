//===----------------------------------------------------------------------===//
//
// PropertiesTests.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import Restore

final class PropertiesTests: XCTestCase {
  class Mock: RestorableObject {
    @Restorable var value1 = "Foo"
    @Restorable var value2 = "Bar"
    @Restorable var value3 = 10000
    @Restorable var value4: Bool? = false
    private var _value5 = 3.14
    var value5: Double {
      get { _value5 }
      set { _value5 = newValue }
    }
    var references: [Reference<Mock>] {
      Reference(object: self, name: "value5", keyPath: \.value5)
    }
  }
  
  func testSomething() {
    let mock = Mock()
    let children = Mirror(reflecting: mock).children
    print(children.map { ($0.label, $0.value) })
  }
  
  func testCreateFromSnapshot() {
    // The values of Properties instances should never
    // be `nil` (assuming the associated values in their
    // snapshots were not `nil`).
    let mock = Mock()
    let snapshot = Snapshot(for: mock)
    let properties = Properties(snapshot)
    
    XCTAssertNotNil(properties.value1)
    XCTAssertNotNil(properties.value2)
    XCTAssertNotNil(properties.value3)
    XCTAssertNotNil(properties.value4)
    XCTAssertNotNil(properties.value5)
  }
  
  func testMaintainsValues() {
    // Properties instances should maintain their values,
    // even when their associated object's values change.
    let mock = Mock()
    let snapshot = Snapshot(for: mock)
    let properties = Properties(snapshot)
    
    XCTAssertEqual(properties.value1, mock.value1)
    XCTAssertEqual(properties.value2, mock.value2)
    XCTAssertEqual(properties.value3, mock.value3)
    XCTAssertEqual(properties.value4, mock.value4)
    XCTAssertEqual(properties.value5, mock.value5)
    
    mock.value1 = "Bar"
    mock.value2 = "Baz"
    mock.value3 = 0
    mock.value4 = true
    mock.value5 = 100.01
    
    XCTAssertNotEqual(properties.value1, mock.value1)
    XCTAssertNotEqual(properties.value2, mock.value2)
    XCTAssertNotEqual(properties.value3, mock.value3)
    XCTAssertNotEqual(properties.value4, mock.value4)
    XCTAssertNotEqual(properties.value5, mock.value5)
  }
  
  func testDuplicateValues() {
    // Properties instances should be able to distinguish
    // between two properties with the same value.
    let mock = Mock()
    let snapshot = Snapshot(for: mock)
    let properties = Properties(snapshot)
    
    XCTAssertEqual(properties.value1, mock.value1)
    XCTAssertNotEqual(properties.value1 as String?, properties.value2 as String?)
  }
}
