import Foundation
import Domain.Protocols
import Domain.Constants
import Domain.ValueObjects
import Infrastructure.Shell

/// Config file writer that handles template addition to config files
public final class ConfigFileWriter {
    private let fileManager: FileManager
    private let shellExecutor: ShellCommandExecutor
    private let logger: OperationLoggerProtocol
    
    public init(fileManager: FileManager = .default, 
         shellExecutor: ShellCommandExecutor = ShellCommandExecutor(),
         logger: OperationLoggerProtocol) {
        self.fileManager = fileManager
        self.shellExecutor = shellExecutor
        self.logger = logger
    }
    
    public func createDefaultConfigIfNeeded(atPath path: FilePath) throws {
        if path.exists(using: fileManager) {
            return
        }
        
        let defaultContent = """
        # See https://pre-commit.com/ for more information
        # See https://pre-commit.com/hooks.html for more hooks
        # This file is managed by the pre-commit-configs installer.
        
        # Default configurations (optional)
        default_stages: [pre-commit] # Sensible default
        default_install_hook_types: [pre-commit, pre-push, commit-msg]
        # default_language_version:
        #   python: python3.9
        
        repos:
        # Add hooks here using the installer or manually
        """
        try defaultContent.write(toFile: path.path, atomically: true, encoding: .utf8)
    }
    
    public func appendTemplate(template: TemplateContent, toConfigAt configPath: FilePath) throws {
        // Add header
        let headerResult = try shellExecutor.executeInBash(script: "echo -e \"\(template.header)\" >> \(configPath.path)")
        if !headerResult.isSuccessful {
            logger.logError(message: "Failed to append template header: \(headerResult.output)")
            return
        }
        
        // Add content
        let fileHandle = try FileHandle(forWritingTo: URL(fileURLWithPath: configPath.path))
        fileHandle.seekToEndOfFile()
        if let data = template.body.data(using: .utf8) {
            fileHandle.write(data)
        }
        try fileHandle.close()
        
        logger.logSuccess(message: "Added template: \(template.header)")
    }
    
    public func appendManagedSectionMarker(toConfigAt configPath: FilePath) throws {
        let marker = ConfigurationConstants.managedSectionMarker
        let markerResult = try shellExecutor.executeInBash(
            script: "grep -q \"\(marker)\" \(configPath.path) || echo -e \"\\n\\n\(marker)\" >> \(configPath.path)"
        )
        
        if !markerResult.isSuccessful {
            logger.logError(message: "Failed to append section marker: \(markerResult.output)")
        }
    }
} 