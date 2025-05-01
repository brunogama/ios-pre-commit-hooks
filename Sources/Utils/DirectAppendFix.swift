import Foundation
import Rainbow

/// Template section marker constants
struct TemplateSectionMarkers {
    static let beginMarker = "# --- BEGIN MANAGED TEMPLATES ---"
    static let endMarker = "# --- END MANAGED TEMPLATES ---"
}

/// Protocol for managing config content
protocol ConfigContentManager {
    func readOrCreateConfig(atPath path: String) throws -> String
}

/// Default implementation of config content manager
final class DefaultConfigContentManager: ConfigContentManager {
    private let fileManager: FileManager
    
    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    func readOrCreateConfig(atPath path: String) throws -> String {
        if fileManager.fileExists(atPath: path) {
            // Read existing config
            return try String(contentsOfFile: path, encoding: .utf8)
        } else {
            // Create default config
            return """
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
        }
    }
}

/// Protocol for template section management
protocol TemplateSectionManager {
    func removeExistingTemplateSection(from content: String) -> String
    func createTemplateSection(with templates: [String]) throws -> String
}

/// Default implementation of template section manager
final class DefaultTemplateSectionManager: TemplateSectionManager {
    private let fileManager: FileManager
    private let logger: ConfigOperationLogger?
    
    init(fileManager: FileManager = .default, logger: ConfigOperationLogger? = nil) {
        self.fileManager = fileManager
        self.logger = logger
    }
    
    func removeExistingTemplateSection(from content: String) -> String {
        var result = content
        
        if let startMarkerRange = result.range(of: TemplateSectionMarkers.beginMarker) {
            if let endMarkerRange = result.range(of: TemplateSectionMarkers.endMarker) {
                let startIndex = startMarkerRange.lowerBound
                let endIndex = result.index(after: endMarkerRange.upperBound)
                result.removeSubrange(startIndex..<endIndex)
            }
        }
        
        return result
    }
    
    func createTemplateSection(with templateDirs: [String]) throws -> String {
        // Prepare the template section
        var templateSection = "\n\(TemplateSectionMarkers.beginMarker)\n"
        
        // Collect all templates
        for templateDir in templateDirs {
            let hooksTemplatesPath = "hooks-templates" as NSString
            let templateDirPath = hooksTemplatesPath.appendingPathComponent(templateDir)
            let templatePath = (templateDirPath as NSString).appendingPathComponent("template.yaml")
            
            if fileManager.fileExists(atPath: templatePath) {
                // Read the raw template content
                let templateContent = try String(contentsOfFile: templatePath, encoding: .utf8)
                
                // Add the template as-is, with its own indentation
                templateSection += templateContent
                
                // Add a newline if not already present
                if !templateContent.hasSuffix("\n") {
                    templateSection += "\n"
                }
                
                logger?.logSuccess(message: "✓ Added raw template from \(templateDir)")
            } else {
                logger?.logWarning(message: "⚠️ Template file not found: \(templatePath)")
            }
        }
        
        // Close the template section
        templateSection += "\(TemplateSectionMarkers.endMarker)\n"
        
        return templateSection
    }
}

/// Main installer for direct template append method
final class DirectTemplateAppender {
    private let contentManager: ConfigContentManager
    private let sectionManager: TemplateSectionManager
    private let logger: ConfigOperationLogger?
    
    init(contentManager: ConfigContentManager = DefaultConfigContentManager(),
         sectionManager: TemplateSectionManager,
         logger: ConfigOperationLogger? = nil) {
        self.contentManager = contentManager
        self.sectionManager = sectionManager
        self.logger = logger
    }
    
    func updateConfig(withTemplates templates: [String], atPath path: String) throws -> String {
        // Read or create config file
        var configContent = try contentManager.readOrCreateConfig(atPath: path)
        
        // Remove any existing templates
        configContent = sectionManager.removeExistingTemplateSection(from: configContent)
        
        // Create and add template section
        let templateSection = try sectionManager.createTemplateSection(with: templates)
        configContent += templateSection
        
        // Write updated config
        try configContent.write(toFile: path, atomically: true, encoding: .utf8)
        
        logger?.logSuccess(message: "✓ Updated config file with \(templates.count) raw templates")
        
        return configContent
    }
}

/// Direct append installer service - no parsing, just directly appending templates
extension InstallerService {
    /// Update config file with selected hook templates - direct append method
    func updateConfigFileWithTemplatesDirect(selectedTemplates: [String]) throws -> [String: CustomStringConvertible] {
        let configPath = Config.configFile
        
        // Create logger that handles the verbose property
        let logger = DefaultConfigOperationLogger(verbose: false) // Avoid direct access to private property
        
        // Create section manager with the logger
        let sectionManager = DefaultTemplateSectionManager(logger: logger)
        
        // Create the main installer
        let installer = DirectTemplateAppender(sectionManager: sectionManager, logger: logger)
        
        // Update config and get the result
        let configContent = try installer.updateConfig(
            withTemplates: selectedTemplates,
            atPath: configPath
        )
        
        return [
            "config": configContent,
            "templates": selectedTemplates
        ]
    }
}
