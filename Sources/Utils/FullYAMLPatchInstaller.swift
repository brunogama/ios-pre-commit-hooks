import Foundation
import Rainbow

/// Template content processor for YAML templates
protocol TemplateContentProcessor {
    func process(_ content: String) -> [String]
}

/// Default YAML template processor
final class YAMLTemplateProcessor: TemplateContentProcessor {
    private let verbose: Bool
    
    init(verbose: Bool = false) {
        self.verbose = verbose
    }
    
    /// Process the full template content for insertion into the config
    /// Preserves ALL content including comments
    func process(_ content: String) -> [String] {
        // Split into lines
        var lines = content.components(separatedBy: .newlines)
        
        // Clean up lines - remove any leading/trailing empty lines only
        while !lines.isEmpty && lines.first!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.removeFirst()
        }
        while !lines.isEmpty && lines.last!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.removeLast()
        }
        
        // Check if first non-comment line starts with "- repo:"
        var foundFirstRepo = false
        for i in 0..<lines.count {
            let trimmed = lines[i].trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmed.hasPrefix("#") && !trimmed.isEmpty {
                if trimmed.hasPrefix("- repo:") || trimmed.hasPrefix("-") {
                    foundFirstRepo = true
                }
                break
            }
        }
        
        // If no repo entry found, we may need to restructure
        if !foundFirstRepo && !lines.isEmpty {
            // This is a simplified approach - in practice you might need more sophisticated parsing
            if verbose {
                print("Warning: Template does not appear to start with a repo entry. It may require manual adjustment.".yellow)
            }
        }
        
        return lines
    }
}

/// ConfigFile creator for creating and modifying YAML config files
protocol ConfigFileCreator {
    func createDefaultConfig() -> String
}

/// Default config file creator implementation
final class DefaultConfigFileCreator: ConfigFileCreator {
    func createDefaultConfig() -> String {
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

/// Marker manager for handling managed section markers in config files
protocol MarkerManager {
    func ensureMarkerExists(in content: String) -> String
}

/// Default marker manager implementation
final class DefaultMarkerManager: MarkerManager {
    private let marker: String
    
    init(marker: String = Config.managedSectionMarker) {
        self.marker = marker
    }
    
    func ensureMarkerExists(in content: String) -> String {
        if content.contains(marker) {
            return content
        }
        
        // Look for repos: section and add marker after it
        if let _ = content.range(of: "repos:") {
            // Find the appropriate insertion point
            var lines = content.components(separatedBy: .newlines)
            let reposLineIndex = lines.firstIndex { $0.contains("repos:") } ?? 0
            
            // Insert marker after any comments following repos:
            var insertLineIndex = reposLineIndex + 1
            while insertLineIndex < lines.count && (lines[insertLineIndex].trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("#") || lines[insertLineIndex].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                insertLineIndex += 1
            }
            
            lines.insert("  \(marker)", at: insertLineIndex)
            return lines.joined(separator: "\n")
        } else {
            // No repos section found, add it with the marker
            return content + """
            
            repos:
              \(marker)
            """
        }
    }
}

/// Template content inserter for adding template content to config files
protocol TemplateContentInserter {
    func insertTemplate(_ templateContent: [String], into configContent: String, after marker: String) -> String
}

/// Default template content inserter implementation
final class DefaultTemplateContentInserter: TemplateContentInserter {
    func insertTemplate(_ templateContent: [String], into configContent: String, after marker: String) -> String {
        let lines = configContent.components(separatedBy: .newlines)
        var newLines = [String]()
        var insertedTemplate = false
        
        for line in lines {
            newLines.append(line)
            if line.contains(marker) && !insertedTemplate {
                // Add template lines after the marker with proper indentation
                let indentedTemplateLines = templateContent.map { "  \($0)" }
                newLines.append(contentsOf: indentedTemplateLines)
                insertedTemplate = true
            }
        }
        
        // If we couldn't find the marker, add at the end
        if !insertedTemplate {
            if !newLines.isEmpty {
                newLines.append("")  // Add empty line for separation
            }
            let indentedTemplateLines = templateContent.map { "  \($0)" }
            newLines.append(contentsOf: indentedTemplateLines)
        }
        
        return newLines.joined(separator: "\n")
    }
}

/// Template file path generator
final class TemplatePathGenerator {
    func generatePath(for templateDir: String) -> String {
        let hooksTemplatesPath = "hooks-templates" as NSString
        let templateDirPath = hooksTemplatesPath.appendingPathComponent(templateDir)
        return (templateDirPath as NSString).appendingPathComponent("template.yaml")
    }
}

/// YAML patch installer that handles full YAML templates
final class FullYAMLPatchInstaller {
    private let fileManager: FileManager
    private let configCreator: ConfigFileCreator
    private let markerManager: MarkerManager
    private let templateProcessor: TemplateContentProcessor
    private let contentInserter: TemplateContentInserter
    private let pathGenerator: TemplatePathGenerator
    private let verbose: Bool
    
    init(fileManager: FileManager = .default,
         configCreator: ConfigFileCreator = DefaultConfigFileCreator(),
         markerManager: MarkerManager = DefaultMarkerManager(),
         templateProcessor: TemplateContentProcessor,
         contentInserter: TemplateContentInserter = DefaultTemplateContentInserter(),
         pathGenerator: TemplatePathGenerator = TemplatePathGenerator(),
         verbose: Bool = false) {
        self.fileManager = fileManager
        self.configCreator = configCreator
        self.markerManager = markerManager
        self.templateProcessor = templateProcessor
        self.contentInserter = contentInserter
        self.pathGenerator = pathGenerator
        self.verbose = verbose
    }
    
    /// Update config file with selected hook templates - fixed version that includes the entire template
    func updateConfigFile(withTemplates selectedTemplates: [String], configPath: String) throws -> String {
        // Create or read existing config
        var configContent = ""
        if fileManager.fileExists(atPath: configPath) {
            configContent = try String(contentsOfFile: configPath, encoding: .utf8)
        } else {
            // Create default config if it doesn't exist
            configContent = configCreator.createDefaultConfig()
            try configContent.write(toFile: configPath, atomically: true, encoding: .utf8)
        }
        
        // Add managed section marker if not present
        configContent = markerManager.ensureMarkerExists(in: configContent)
        try configContent.write(toFile: configPath, atomically: true, encoding: .utf8)
        
        // Process each template
        for templateDir in selectedTemplates {
            let templatePath = pathGenerator.generatePath(for: templateDir)
            
            if fileManager.fileExists(atPath: templatePath) {
                let templateContent = try String(contentsOfFile: templatePath, encoding: .utf8)
                
                // Process the template content - PRESERVE EVERYTHING including comments
                if !templateContent.isEmpty {
                    // Process the template content
                    let processedLines = templateProcessor.process(templateContent)
                    
                    // Add template to config content
                    configContent = contentInserter.insertTemplate(
                        processedLines,
                        into: configContent,
                        after: Config.managedSectionMarker
                    )
                    
                    if verbose {
                        print("✓ Added template from \(templateDir)".green)
                    }
                }
            } else if verbose {
                print("⚠️ Template file not found: \(templatePath)".yellow)
            }
        }
        
        // Write updated config
        try configContent.write(toFile: configPath, atomically: true, encoding: .utf8)
        
        if verbose {
            print("✓ Updated config file with selected templates".green)
        }
        
        return configContent
    }
}

/// Installer service extension to use the full YAML patch installer
extension InstallerService {
    /// Update config file with selected hook templates - fixed version that includes the entire template
    func updateConfigFileWithTemplatesFullYAML(selectedTemplates: [String]) throws -> [String: CustomStringConvertible] {
        let configPath = Config.configFile
        
        // Create the processor with the verbose flag from this service
        let processor = YAMLTemplateProcessor(verbose: false) // Avoid direct access to private property
        
        // Create and use the installer
        let installer = FullYAMLPatchInstaller(
            templateProcessor: processor,
            verbose: false // Avoid direct access to private property
        )
        
        let configContent = try installer.updateConfigFile(
            withTemplates: selectedTemplates,
            configPath: configPath
        )
        
        return [
            "config": configContent,
            "templates": selectedTemplates
        ]
    }
}
