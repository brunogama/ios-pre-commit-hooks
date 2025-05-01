import Foundation
import Rainbow
import Domain.Protocols

/// Default implementation of operation logger
public final class OperationLogger: OperationLoggerProtocol {
    private let isVerbose: Bool
    
    public init(isVerbose: Bool = false) {
        self.isVerbose = isVerbose
    }
    
    public func logInfo(message: String) {
        if isVerbose {
            print(message)
        }
    }
    
    public func logSuccess(message: String) {
        if isVerbose {
            print(message.green)
        }
    }
    
    public func logError(message: String) {
        print(message.red)
    }
} 