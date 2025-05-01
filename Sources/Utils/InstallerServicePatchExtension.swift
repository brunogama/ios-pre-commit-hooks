import Foundation
import Application.Services
import Domain.Constants
import Infrastructure.Registry
import Infrastructure.Logging
import OSLog

/// InstallerService logger implementation
private class InstallerServiceLogger: OperationLoggerProtocol {
    private let logger: Logger
    private let installerService: InstallerService
    
    init(installerService: InstallerService) {
        self.installerService = installerService
        self.logger = Logger(subsystem: "com.pre-commit-configs", category: "InstallerService")
    }
    
    func info(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }
    
    func success(_ message: String) {
        logger.notice("✅ \(message, privacy: .public)")
    }
    
    func error(_ message: String) {
        logger.error("❌ \(message, privacy: .public)")
    }
    
    func debug(_ message: String) {
        logger.debug("\(message, privacy: .public)")
    }
    
    func warning(_ message: String) {
        logger.warning("⚠️ \(message, privacy: .public)")
    }
}

/// This extension contains the complete patch installer implementation
extension InstallerService {
    /// Update config file with selected hook templates using shell commands
    func updateConfigFileWithTemplatesComplete(selectedTemplates: [String]) throws -> [String: CustomStringConvertible] {
        // Create a logger that will only display messages if this service has verbose=true
        let conditionalLogger = InstallerServiceLogger(installerService: self)
        
        // Create the component implementations
        let templateRegistry = TemplateRegistry()
        let configWriter = ConfigFileWriter(logger: conditionalLogger)
        
        // Create and use the installer
        let installer = CompletePatchInstaller(
            templateRegistry: templateRegistry,
            configWriter: configWriter,
            logger: conditionalLogger
        )
        
        return try installer.updateConfigFile(
            withTemplates: selectedTemplates,
            atPath: ConfigurationConstants.configFile
        )
    }
} 