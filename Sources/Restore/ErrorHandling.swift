//===----------------------------------------------------------------------===//
//
// ErrorHandling.swift
//
// Created: 2022. Author: Jordan Baird.
//
//===----------------------------------------------------------------------===//

// MARK: - GeneralError

protocol GeneralError: Error {
  var message: String { get }
  init(message: String)
}

extension GeneralError {
  init(_ message: String) {
    self.init(message: message)
  }
}

// MARK: - RestorationError

struct RestorationError: GeneralError {
  let message: String
}

extension RestorationError {
  static let unknownProperty = Self("Unknown property. Cannot restore value.")
  
  static func noValues(forProperies properties: [String]) -> Self {
    .init("No stored values exist for properties \"\(properties)\".")
  }
  
  static func noSnapshot(forKey key: RestorationKey) -> Self {
    .init("No snapshot exists for key \"\(key.rawValue)\".")
  }
}
