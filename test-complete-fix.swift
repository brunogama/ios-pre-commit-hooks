#!/usr/bin/env swift

import Foundation

print("Testing Complete Template Preservation")
print("=====================================")

// Setup test paths
let basePath = "/Users/bruno/Developer/pre-commit-configs"
let configPath = "\(basePath)/test-complete-config.yaml"

// Initialize test templates
let swiftlintDir = "swiftlint"
let swiftformatDir = "swiftformat"

// Read template files for verification
let swiftlintPath = "\(basePath)/hooks-templates/\(swiftlintDir)/template.yaml"
let swiftformatPath = "\(basePath)/hooks-templates/\(swiftformatDir)/template.yaml"

func readTemplate(path: String) -> String? {
    return try? String(contentsOfFile: path, encoding: .utf8)
}

print("Reading template files:")
print("1. SwiftLint template:")
if let swiftlintTemplate = readTemplate(path: swiftlintPath) {
    print(swiftlintTemplate)
} else {
    print("Error: Could not read SwiftLint template file")
}

print("\n2. SwiftFormat template:")
if let swiftformatTemplate = readTemplate(path: swiftformatPath) {
    print(swiftformatTemplate)
} else {
    print("Error: Could not read SwiftFormat template file")
}

// Create a handler to test template preservation
class TemplatePreservationHandler {
    let fileManager = FileManager.default
    
    func addTemplatesToConfig(templateDirs: [String], configPath: String) throws {
        // Create or read existing config
        var configContent = ""
        if fileManager.fileExists(atPath: configPath) {
            configContent = try String(contentsOfFile: configPath, encoding: .utf8)
        } else {
            // Create default config
            configContent = """
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
            try configContent.write(toFile: configPath, atomically: true, encoding: .utf8)
        }
        
        // Add managed section marker if not present
        let managedMarker = "# --- Managed by pre-commit-configs installer ---"
        if !configContent.contains(managedMarker) {
            var lines = configContent.components(separatedBy: .newlines)
            let reposLineIndex = lines.firstIndex { $0.contains("repos:") } ?? 0
            var insertLineIndex = reposLineIndex + 1
            
            // Skip comments and empty lines
            while insertLineIndex < lines.count && (lines[insertLineIndex].trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("#") || lines[insertLineIndex].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                insertLineIndex += 1
            }
            
            lines.insert("  \(managedMarker)", at: insertLineIndex)
            configContent = lines.joined(separator: "\n")
            try configContent.write(toFile: configPath, atomically: true, encoding: .utf8)
        }
        
        // Process each template
        for templateDir in templateDirs {
            let hooksTemplatesPath = "\(basePath)/hooks-templates" as NSString
            let templateDirPath = hooksTemplatesPath.appendingPathComponent(templateDir)
            let templatePath = (templateDirPath as NSString).appendingPathComponent("template.yaml")
            
            if fileManager.fileExists(atPath: templatePath) {
                // Read the template content
                let templateContent = try String(contentsOfFile: templatePath, encoding: .utf8)
                
                // Process the template content - keep everything EXACTLY as is
                if !templateContent.isEmpty {
                    let lines = configContent.components(separatedBy: .newlines)
                    var newLines = [String]()
                    var insertedTemplate = false
                    
                    for line in lines {
                        newLines.append(line)
                        if line.contains(managedMarker) && !insertedTemplate {
                            // Add an empty line for separation
                            newLines.append("")
                            
                            // Add the entire template with correct indentation
                            let templateLines = templateContent.components(separatedBy: .newlines)
                            for templateLine in templateLines {
                                if !templateLine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    newLines.append("  \(templateLine)")
                                }
                            }
                            insertedTemplate = true
                        }
                    }
                    
                    configContent = newLines.joined(separator: "\n")
                    print("✓ Added template from \(templateDir)")
                }
            } else {
                print("⚠️ Template file not found: \(templatePath)")
            }
        }
        
        // Write updated config
        try configContent.write(toFile: configPath, atomically: true, encoding: .utf8)
        print("✓ Updated config file with selected templates")
        
        // Read and display the final config
        let finalConfig = try String(contentsOfFile: configPath, encoding: .utf8)
        print("\nFinal config content:")
        print(finalConfig)
    }
}

// Run the test
print("\nTesting template preservation...")
do {
    let handler = TemplatePreservationHandler()
    try handler.addTemplatesToConfig(templateDirs: [swiftlintDir, swiftformatDir], configPath: configPath)
    print("\nTest completed successfully!")
} catch {
    print("Error: \(error)")
}
