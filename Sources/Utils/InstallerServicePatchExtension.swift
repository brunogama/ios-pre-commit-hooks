import Foundation
import Application.Services
import Domain.Constants
import Infrastructure.Registry
import Infrastructure.Logging

/// InstallerService logger implementation
private class InstallerServiceLogger: OperationLoggerProtocol {
    private let installerService: InstallerService
    
    init(installerService: InstallerService) {
        self.installerService = installerService
    }
    
    func logInfo(message: String) {
        print(message)
    }
    
    func logSuccess(message: String) {
        print(message.green)
    }
    
    func logError(message: String) {
        print(message.red)
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