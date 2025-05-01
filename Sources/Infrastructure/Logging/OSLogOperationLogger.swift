import Domain.Protocols
import Foundation
import OSLog

/// Implementation of OperationLoggerProtocol using modern OSLog framework
public final class OperationLogger: OperationLoggerProtocol {
    private let logger: Logger
    private let isVerbose: Bool
    
    /// Initialize a new logger with specified subsystem and category
    /// - Parameters:
    ///   - subsystem: The subsystem identifier, typically reverse-DNS notation (e.g., "com.yourapp.domain")
    ///   - category: The category for this logger, typically the component name (e.g., "networking")
    ///   - isVerbose: Whether to show all messages including debug level
    public init(subsystem: String, category: String, isVerbose: Bool = false) {
        self.logger = Logger(subsystem: subsystem, category: category)
        self.isVerbose = isVerbose
    }
    
    /// Log information message
    /// - Parameter message: The message to log
    public func info(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }
    
    /// Log success message
    /// - Parameter message: The message to log
    public func success(_ message: String) {
        logger.notice("✅ \(message, privacy: .public)")
    }
    
    /// Log error message
    /// - Parameter message: The message to log
    public func error(_ message: String) {
        logger.error("❌ \(message, privacy: .public)")
    }
    
    /// Log debug message (only shown when verbose or debugger attached)
    /// - Parameter message: The message to log
    public func debug(_ message: String) {
        if isVerbose {
            logger.debug("\(message, privacy: .public)")
        }
    }
    
    /// Log warning message
    /// - Parameter message: The message to log
    public func warning(_ message: String) {
        logger.warning("⚠️ \(message, privacy: .public)")
    }
} 