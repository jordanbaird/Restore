//===----------------------------------------------------------------------===//
//
// RestorableTests.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

import XCTest
@testable import Restore

final class RestorableTests: XCTestCase {
  class RestorableMock1: RestorableObject {
    @Restorable var value1 = "Foo"
    @Restorable var value2: Int? = 100
    var value3 = true
    var references: [Reference<RestorableMock1>] {
      Reference(owner: self, name: "value3", keyPath: \.value3)
    }
  }
  
  class RestorableMock2: RestorableObject {
    @Restorable var value1 = 8.2375
    @Restorable var value2 = false
  }
  
  struct RestorableMock3: RestorableObject {
    let restorableObjectIdentifier = Identifier()
  }
  
  override func setUp() {
    storage.removeAll()
  }
  
  func testSnapshot() throws {
    let mock = RestorableMock1()
    
    XCTAssertEqual(mock.value1, "Foo")
    XCTAssertEqual(mock.value2, 100)
    
    mock.takeSnapshot(withKey: "Snapshot1")
    
    mock.value1 = "Bar"
    mock.value2 = 1000
    
    XCTAssertEqual(mock.value1, "Bar")
    XCTAssertEqual(mock.value2, 1000)
    
    try mock.restore(withKey: "Snapshot1")
  }
  
  func testMultipleSnapshots() throws {
    func assertOriginalValues() {
      XCTAssertEqual(mock.value1, "Foo")
      XCTAssertEqual(mock.value2, 100)
    }
    
    func assertNewValues() {
      XCTAssertEqual(mock.value1, "Bar")
      XCTAssertEqual(mock.value2, 1000)
    }
    
    func setNewValues() {
      mock.value1 = "Bar"
      mock.value2 = 1000
    }
    
    let mock = RestorableMock1()
    
    assertOriginalValues()
    
    mock.takeSnapshot(withKey: "Snapshot1")
    
    setNewValues()
    assertNewValues()
    
    mock.takeSnapshot(withKey: "Snapshot2")
    try mock.restore(withKey: "Snapshot1")
    
    assertOriginalValues()
    
    try mock.restore(withKey: "Snapshot2")
    
    assertNewValues()
  }
  
  func testCollisions() throws {
    func assertOriginalValues() {
      XCTAssertEqual(mock1.value1, "Foo")
      XCTAssertEqual(mock1.value2, 100)
      
      XCTAssertEqual(mock2.value1, 8.2375)
      XCTAssertEqual(mock2.value2, false)
    }
    
    func assertNewValues() {
      XCTAssertEqual(mock1.value1, "Bar")
      XCTAssertEqual(mock1.value2, nil)
      
      XCTAssertEqual(mock2.value1, 100_000.7)
      XCTAssertEqual(mock2.value2, true)
    }
    
    func setNewValues() {
      mock1.value1 = "Bar"
      mock1.value2 = nil
      
      mock2.value1 = 100_000.7
      mock2.value2 = true
    }
    
    let mock1 = RestorableMock1()
    let mock2 = RestorableMock2()
    
    assertOriginalValues()
    
    mock1.takeSnapshot(withKey: "SomeKey")
    mock2.takeSnapshot(withKey: "SomeKey")
    
    setNewValues()
    assertNewValues()
    
    try mock1.restore(withKey: "SomeKey")
    try mock2.restore(withKey: "SomeKey")
    
    assertOriginalValues()
  }
  
  func testRestoreSeparateInstanceFails() throws {
    let original = RestorableMock1()
    original.takeSnapshot(withKey: "Original")
    
    let new = RestorableMock1()
    XCTAssertThrowsError(try new.restore(withKey: "Original"))
  }
  
  func testRestoreSingleValue() throws {
    let mock = RestorableMock1()
    
    mock.takeSnapshot(withKey: "SomeKey")
    mock.value1 = "Bar"
    mock.value2 = 73801
    
    try mock.restore(\.$value1, withKey: "SomeKey")
    XCTAssertEqual(mock.value1, "Foo")
    XCTAssertEqual(mock.value2, 73801)
    
    try mock.restore(\.$value2, withKey: "SomeKey")
    XCTAssertEqual(mock.value2, 100)
  }
  
  func testRetrieveProperties() throws {
    let mock = RestorableMock1()
    mock.takeSnapshot(withKey: "SomeKey")
    
    let properties = try mock.properties(withKey: "SomeKey")
    XCTAssertEqual(properties.value1, "Foo")
    XCTAssertEqual(properties.value2, 100)
    XCTAssertEqual(properties.value3, true)
  }
  
  func testNoSnapshot() throws {
    let mock = RestorableMock1()
    XCTAssertThrowsError(try mock.restore(withKey: "SomeKey"))
    XCTAssertThrowsError(try mock.restore(\.$value1, withKey: "SomeKey"))
  }
  
  func testNoProperties() throws {
    let mock = RestorableMock1()
    XCTAssertThrowsError(try mock.properties(withKey: "SomeKey"))
  }
  
  func testNoValues() throws {
    let mock1 = RestorableMock1()
    let mock2 = RestorableMock1()
    mock1.takeSnapshot(withKey: "SomeKey")
    XCTAssertThrowsError(try mock2.restore(withKey: "SomeKey"))
  }
  
  func testRestorationKey() {
    let key1: RestorationKey = "Key"
    let key2 = RestorationKey(rawValue: "Key")
    let key3 = RestorationKey("Key")
    XCTAssertEqual(key1, key2)
    XCTAssertEqual(key2, key3)
  }
  
  func testPropertiesSubscript() throws {
    let mock = RestorableMock1()
    mock.takeSnapshot(withKey: "SomeKey")
    let properties = try mock.properties(withKey: "SomeKey")
    let v1: String? = properties.value1
    let v2: String? = properties["value1"]
    XCTAssertEqual(v1, v2)
  }
  
  func testNested() {
    @Restorable(state: .nested) var r1: Any = Restorable("Foo")
    XCTAssertTrue(r1 is String)
    
    @Restorable(state: .standard) var r2: Any = Restorable("Bar")
    XCTAssertTrue(r2 is Restorable<String>)
  }
  
  func testDirectInitialization() {
    let r1 = Restorable<String?>(state: .standard)
    XCTAssertNil(r1.wrappedValue)
  }
  
  func testRemoveLocalSnapshots() {
    let mock1 = RestorableMock1()
    let mock2 = RestorableMock1()
    let mock3 = RestorableMock2()
    
    mock1.takeSnapshot(withKey: "SomeKey1")
    mock1.takeSnapshot(withKey: "SomeKey2")
    mock1.takeSnapshot(withKey: "SomeKey3")
    
    mock2.takeSnapshot(withKey: "SomeKey1")
    mock2.takeSnapshot(withKey: "SomeKey2")
    mock2.takeSnapshot(withKey: "SomeKey3")
    
    mock3.takeSnapshot(withKey: "SomeKey1")
    mock3.takeSnapshot(withKey: "SomeKey2")
    mock3.takeSnapshot(withKey: "SomeKey3")
    
    XCTAssertEqual(mock1.snapshots.count, 3)
    XCTAssertEqual(mock2.snapshots.count, 3)
    XCTAssertEqual(mock3.snapshots.count, 3)
    
    mock1.removeSnapshot(withKey: "SomeKey1")
    XCTAssertEqual(mock1.snapshots.count, 2)
    XCTAssertEqual(mock2.snapshots.count, 3)
    XCTAssertEqual(mock3.snapshots.count, 3)
    
    mock1.removeLocalSnapshots()
    XCTAssertEqual(mock1.snapshots.count, 0)
    XCTAssertEqual(mock2.snapshots.count, 3)
    XCTAssertEqual(mock3.snapshots.count, 3)
    
    mock3.removeLocalSnapshots()
    XCTAssertEqual(mock3.snapshots.count, 0)
    XCTAssertEqual(mock2.snapshots.count, 3)
  }
  
  func testIdentifierForClass() {
    let mock1 = RestorableMock1()
    let mock2 = RestorableMock1()
    
    let id1 = Identifier(for: mock1)
    let id2 = Identifier(for: mock1)
    XCTAssertEqual(id1, id2)
    
    let id3 = Identifier(for: mock2)
    XCTAssertNotEqual(id2, id3)
  }
  
  func testReferenceTypeIdentifier() {
    let mock1 = RestorableMock1()
    let mock2 = RestorableMock2()
    XCTAssertNotEqual(mock1.restorableObjectIdentifier, mock2.restorableObjectIdentifier)
  }
  
  func testValueTypeIdentifier() {
    let mock1 = RestorableMock3()
    let mock2 = RestorableMock3()
    XCTAssertNotEqual(mock1.restorableObjectIdentifier, mock2.restorableObjectIdentifier)
  }
  
  func testDescriptions() {
    @Restorable var value1 = "Foo"
    let value2 = Restorable(value: "Bar")
    
    XCTAssertEqual($value1.description, "Restorable<String>(Foo)")
    XCTAssertEqual(value2.description, "Restorable<String>(Bar)")
    
    XCTAssertEqual($value1.debugDescription, "Restorable<String>(wrappedValue: Foo)")
    XCTAssertEqual(value2.debugDescription, "Restorable<String>(wrappedValue: Bar)")
  }
  
  func testReferences() throws {
    let mock = RestorableMock1()
    XCTAssertEqual(mock.value3, true)
    
    mock.takeSnapshot(withKey: "SomeKey")
    mock.value3 = false
    XCTAssertEqual(mock.value3, false)
    
    try mock.restore(withKey: "SomeKey")
    XCTAssertEqual(mock.value3, true)
  }
  
  func testRestorableEquality() {
    let mock = RestorableMock1()
    let copy = Restorable(other: mock.$value1)
    XCTAssertEqual(mock.$value1.wrappedValue, copy.wrappedValue)
  }
}
