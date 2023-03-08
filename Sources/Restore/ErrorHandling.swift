//
// ErrorHandling.swift
// Restore
//

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
    static func noSnapshot(forKey key: RestorationKey) -> Self {
        .init("No snapshot exists for key \(key.rawValue).")
    }
}
