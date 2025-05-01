#!/usr/bin/env swift

import Foundation

// Quick test script to verify template handling

// Get path
let currentDirectory = FileManager.default.currentDirectoryPath
let basePath = "/Users/bruno/Developer/pre-commit-configs"
let templatePath = "\(basePath)/hooks-templates/swiftlint/template.yaml"
let configPath = "\(basePath)/test-fixed-config.yaml"

// Logging
func log(_ message: String) {
    print(message)
}

// Create test config
let defaultConfig = """
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

// YAML Template Handler implementation
class YAMLTemplateHandler {
    private let fileManager = FileManager.default
    private let basePath: String
    
    init(basePath: String) {
        self.basePath = basePath
    }
    
    /// Process templates and properly add them to the config file
    func addTemplatesToConfig(selectedTemplates: [String], configPath: String) throws {
        // Create or read existing config
        var configContent = ""
        if fileManager.fileExists(atPath: configPath) {
            configContent = try String(contentsOfFile: configPath, encoding: .utf8)
        } else {
            // Create default config if it doesn't exist
            configContent = defaultConfig
            try configContent.write(toFile: configPath, atomically: true, encoding: .utf8)
        }
        
        // Add managed section marker if not present
        let managedMarker = "# --- Managed by pre-commit-configs installer ---"
        if !configContent.contains(managedMarker) {
            // Look for repos: section and add marker after it
            if let _ = configContent.range(of: "repos:") {
                // Find the appropriate insertion point
                var lines = configContent.components(separatedBy: .newlines)
                let reposLineIndex = lines.firstIndex { $0.contains("repos:") } ?? 0
                
                // Insert marker after any comments following repos:
                var insertLineIndex = reposLineIndex + 1
                while insertLineIndex < lines.count && (lines[insertLineIndex].trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("#") || lines[insertLineIndex].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                    insertLineIndex += 1
                }
                
                lines.insert("  \(managedMarker)", at: insertLineIndex)
                configContent = lines.joined(separator: "\n")
            } else {
                // No repos section found, add it with the marker
                configContent += """
                
                repos:
                  \(managedMarker)
                """
            }
            
            // Save the updated config with marker
            try configContent.write(toFile: configPath, atomically: true, encoding: .utf8)
        }
        
        // Process each template
        for templateDir in selectedTemplates {
            let hooksTemplatesPath = "\(basePath)/hooks-templates" as NSString
            let templateDirPath = hooksTemplatesPath.appendingPathComponent(templateDir)
            let templatePath = (templateDirPath as NSString).appendingPathComponent("template.yaml")
            
            if fileManager.fileExists(atPath: templatePath) {
                let templateContent = try String(contentsOfFile: templatePath, encoding: .utf8)
                
                // Extract template entries
                let processedTemplate = processTemplate(templateContent)
                if !processedTemplate.isEmpty {
                    // Add template to config content
                    let lines = configContent.components(separatedBy: .newlines)
                    var newLines = [String]()
                    var insertedTemplate = false
                    
                    for line in lines {
                        newLines.append(line)
                        if line.contains(managedMarker) && !insertedTemplate {
                            // Add template lines after the marker with proper indentation
                            let templateLines = processedTemplate.components(separatedBy: .newlines)
                                .map { "  \($0)" } // Add proper indentation
                            newLines.append(contentsOf: templateLines)
                            insertedTemplate = true
                        }
                    }
                    
                    // If we couldn't find the marker, add at the end
                    if !insertedTemplate {
                        let templateLines = processedTemplate.components(separatedBy: .newlines)
                            .map { "  \($0)" } // Add proper indentation
                        newLines.append(contentsOf: templateLines)
                    }
                    
                    configContent = newLines.joined(separator: "\n")
                    log("✓ Added template from \(templateDir)")
                }
            } else {
                log("⚠️ Template file not found: \(templatePath)")
            }
        }
        
        // Write updated config
        try configContent.write(toFile: configPath, atomically: true, encoding: .utf8)
        log("✓ Updated config file with selected templates")
    }
    
    /// Process a template file content for proper insertion into the config
    private func processTemplate(_ content: String) -> String {
        // Remove first comment line if it exists
        var lines = content.components(separatedBy: .newlines)
        
        // Clean up lines - remove any leading/trailing empty lines
        while !lines.isEmpty && lines.first!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.removeFirst()
        }
        while !lines.isEmpty && lines.last!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.removeLast()
        }
        
        // Skip first line if it's a comment (usually the template title)
        if !lines.isEmpty && lines.first!.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("#") {
            lines.removeFirst()
        }
        
        // Process remaining lines to ensure proper YAML structure
        return lines.joined(separator: "\n")
    }
}

// Run the test
do {
    log("Starting YAML template handling test...")
    log("Current directory: \(currentDirectory)")
    log("Base path: \(basePath)")
    log("Template path: \(templatePath)")
    
    // Write default config if needed
    if !FileManager.default.fileExists(atPath: configPath) {
        try defaultConfig.write(toFile: configPath, atomically: true, encoding: .utf8)
    }
    
    // Read the template for reference
    let templateContent = try String(contentsOfFile: templatePath, encoding: .utf8)
    log("Template content:")
    log(templateContent)
    
    // Use our handler to add the template
    let handler = YAMLTemplateHandler(basePath: basePath)
    try handler.addTemplatesToConfig(selectedTemplates: ["swiftlint"], configPath: configPath)
    
    // Read and print the result
    let result = try String(contentsOfFile: configPath, encoding: .utf8)
    log("\nUpdated config content:")
    log(result)
    
    log("\nTest completed successfully!")
} catch {
    log("Error: \(error)")
}
