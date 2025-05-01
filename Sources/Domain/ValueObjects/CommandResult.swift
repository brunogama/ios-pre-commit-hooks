import Foundation

/// Shell command result
public final class CommandResult {
    public let exitCode: Int
    public let output: String
    
    public init(exitCode: Int, output: String) {
        self.exitCode = exitCode
        self.output = output
    }
    
    public var isSuccessful: Bool {
        return exitCode == 0
    }
} 