import Foundation

/// Factory for creating loggers with consistent configuration
public final class LoggerFactory {
    private let appBundleID: String
    private let isVerbose: Bool
    
    /// Initialize a logger factory
    /// - Parameters:
    ///   - appBundleID: The application bundle ID (used as base for subsystem)
    ///   - isVerbose: Whether created loggers should be verbose by default
    public init(appBundleID: String = Bundle.main.bundleIdentifier ?? "com.app", isVerbose: Bool = false) {
        self.appBundleID = appBundleID
        self.isVerbose = isVerbose
    }
    
    /// Create a logger for a specific component
    /// - Parameter category: The component or category name
    /// - Returns: A configured logger
    public func createLogger(category: String) -> OperationLoggerProtocol {
        OperationLogger(
            subsystem: appBundleID,
            category: category,
            isVerbose: isVerbose
        )
    }
    
    /// Create a logger for a specific component and domain
    /// - Parameters:
    ///   - domain: The domain (e.g., "networking", "database")
    ///   - category: The component or category name
    /// - Returns: A configured logger
    public func createDomainLogger(domain: String, category: String) -> OperationLoggerProtocol {
        OperationLogger(
            subsystem: "\(appBundleID).\(domain)",
            category: category,
            isVerbose: isVerbose
        )
    }
} 