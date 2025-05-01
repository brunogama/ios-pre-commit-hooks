import Foundation

/// Interface for logging operations
public protocol OperationLoggerProtocol {
    /// Log an informational message
    func info(_ message: String)
    
    /// Log a success message
    func success(_ message: String)
    
    /// Log an error message
    func error(_ message: String)
    
    /// Log a debug message
    func debug(_ message: String)
    
    /// Log a warning message
    func warning(_ message: String)
} 