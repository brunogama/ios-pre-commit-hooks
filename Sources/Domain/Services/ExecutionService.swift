import Foundation

/// Domain service for executing shell commands
public protocol ExecutionService {
    /// Execute a shell command with arguments
    /// - Parameters:
    ///   - command: The command to execute
    ///   - arguments: Arguments to pass to the command
    /// - Throws: Error if execution fails
    func execute(command: String, arguments: [String]) throws
    
    /// Execute a script in bash
    /// - Parameter script: The script to execute
    /// - Throws: Error if execution fails
    func executeInBash(script: String) throws
    
    /// Execute a command and return its output
    /// - Parameters:
    ///   - command: The command to execute
    ///   - arguments: Arguments to pass to the command
    /// - Returns: The output from the command as a string
    /// - Throws: Error if execution fails
    func executeWithOutput(command: String, arguments: [String]) throws -> String
} 