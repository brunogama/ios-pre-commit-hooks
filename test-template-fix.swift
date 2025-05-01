#!/usr/bin/env swift

import Foundation

print("Testing full template handling...")

// Setup test paths
let basePath = "/Users/bruno/Developer/pre-commit-configs"
let templateDir = "swiftlint"
let configPath = "/Users/bruno/Developer/pre-commit-configs/test-full-config.yaml"

// Create a class to test the template handling
class TemplateHandler {
    let fileManager = FileManager.default
    
    func addTemplateToConfig(templateDir: String, configPath: String) throws {
        // Create or read existing config
        var configContent = ""
        if fileManager.fileExists(atPath: configPath) {
            configContent = try String(contentsOfFile: configPath, encoding: .utf8)
        } else {
            // Create default config
            configContent = "# See https://pre-commit.com/ for more information\n# See https://pre-commit.com/hooks.html for more hooks\n# This file is managed by the pre-commit-configs installer.\n# Default configurations (optional)\ndefault_stages: [pre-commit] # Sensible default\ndefault_install_hook_types: [pre-commit, pre-push, commit-msg]\n# default_language_version:\n#   python: python3.9\nrepos:\n  # Add hooks here using the installer or manually"
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
        
        // Process template
        let hooksTemplatesPath = "\(basePath)/hooks-templates" as NSString
        let templateDirPath = hooksTemplatesPath.appendingPathComponent(templateDir)
        let templatePath = (templateDirPath as NSString).appendingPathComponent("template.yaml")
        
        if fileManager.fileExists(atPath: templatePath) {
            let templateContent = try String(contentsOfFile: templatePath, encoding: .utf8)
            print("\nTemplate content:")
            print(templateContent)
            
            // Process the template content - PRESERVE EVERYTHING including comments
            if !templateContent.isEmpty {
                let lines = configContent.components(separatedBy: .newlines)
                var newLines = [String]()
                var insertedTemplate = false
                
                for line in lines {
                    newLines.append(line)
                    if line.contains(managedMarker) && !insertedTemplate {
                        // Split template into lines and indent properly
                        let templateLines = processTemplate(templateContent)
                            .map { "  \($0)" }
                        newLines.append(contentsOf: templateLines)
                        insertedTemplate = true
                    }
                }
                
                configContent = newLines.joined(separator: "\n")
                try configContent.write(toFile: configPath, atomically: true, encoding: .utf8)
                
                // Read and show the result
                let resultContent = try String(contentsOfFile: configPath, encoding: .utf8)
                print("\nUpdated config file:")
                print(resultContent)
                
                print("\n✓ Template added successfully")
            }
        } else {
            print("Error: Template file not found at \(templatePath)")
        }
    }
    
    private func processTemplate(_ content: String) -> [String] {
        // Split into lines
        var lines = content.components(separatedBy: .newlines)
        
        // Clean up lines - remove any leading/trailing empty lines only
        while !lines.isEmpty && lines.first!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.removeFirst()
        }
        while !lines.isEmpty && lines.last!.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            lines.removeLast()
        }
        
        return lines
    }
}

// Run test
do {
    let handler = TemplateHandler()
    try handler.addTemplateToConfig(templateDir: templateDir, configPath: configPath)
} catch {
    print("Error: \(error)")
}