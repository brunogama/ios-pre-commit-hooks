import Foundation
import Domain.ValueObjects

/// Shell command executor that handles running shell commands
public final class ShellCommandExecutor {
    public init() {}
    
    public func execute(command: String, arguments: [String]) throws -> CommandResult {
        let process = Process()
        let pipe = Pipe()
        
        process.executableURL = URL(fileURLWithPath: command)
        process.arguments = arguments
        process.standardOutput = pipe
        process.standardError = pipe
        
        try process.run()
        process.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        return CommandResult(exitCode: Int(process.terminationStatus), output: output)
    }
    
    public func executeInBash(script: String) throws -> CommandResult {
        return try execute(command: "/bin/bash", arguments: ["-c", script])
    }
} 