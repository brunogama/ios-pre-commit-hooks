import Foundation

/// Interface for logging operations
public protocol OperationLoggerProtocol {
    func logInfo(message: String)
    func logSuccess(message: String)
    func logError(message: String)
} 