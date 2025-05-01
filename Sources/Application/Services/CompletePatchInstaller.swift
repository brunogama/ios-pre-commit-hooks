import Domain.Protocols
import Domain.ValueObjects
import Foundation

/// Complete patch installer service
public final class CompletePatchInstaller {
    private let templateRegistry: TemplateRegistryProtocol
    private let configWriter: ConfigFileWriter
    private let fileManager: FileManager
    private let logger: OperationLoggerProtocol
    
    public init(templateRegistry: TemplateRegistryProtocol,
                configWriter: ConfigFileWriter,
                fileManager: FileManager = .default,
                logger: OperationLoggerProtocol)
    {
        self.templateRegistry = templateRegistry
        self.configWriter = configWriter
        self.fileManager = fileManager
        self.logger = logger
    }
    
    public func updateConfigFile(withTemplates selectedTemplateNames: [String], atPath configPath: String) throws -> [String: CustomStringConvertible] {
        let configFilePath = FilePath(configPath)
        try configWriter.createDefaultConfigIfNeeded(atPath: configFilePath)
        
        let templateNames = selectedTemplateNames.map { TemplateName($0) }
        
        for templateName in templateNames {
            guard let templatePath = templateRegistry.templatePath(for: templateName) else {
                logger.error("Template not found: \(templateName.name)")
                continue
            }
            
            if let templateContent = try? String(contentsOfFile: templatePath.path, encoding: .utf8) {
                let template = TemplateContent(name: templateName, content: templateContent)
                try configWriter.appendTemplate(template: template, toConfigAt: configFilePath)
            }
        }
        
        try configWriter.appendManagedSectionMarker(toConfigAt: configFilePath)
        
        let configContent = try String(contentsOfFile: configFilePath.path, encoding: .utf8)
        
        return [
            "config": configContent,
            "templates": selectedTemplateNames
        ]
    }
} 