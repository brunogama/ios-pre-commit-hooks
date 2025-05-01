#!/usr/bin/env swift

import Foundation

print("Testing Multiple Template Handling")
print("=================================")

// Setup test paths
let basePath = "/Users/bruno/Developer/pre-commit-configs"
let configPath = "\(basePath)/test-multiple-config.yaml"

// Define multiple test templates to ensure we test with more than one
let testTemplates = ["swiftlint", "swiftformat", "swiftgen"]

// Clean up any existing test file
let fileManager = FileManager.default
if fileManager.fileExists(atPath: configPath) {
    try fileManager.removeItem(atPath: configPath)
    print("✓ Removed existing test config file")
}

// Create a class to test the multiple template handling using our fixed logic
class MultipleTemplatesHandler {
    let fileManager = FileManager.default
    let basePath: String
    
    init(basePath: String) {
        self.basePath = basePath
    }
    
    func addTemplatesToConfig(templateDirs: [String], configPath: String) throws {
        // Create or read existing config
        var configContent = """
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
        print("✓ Created initial config file")
        
        // Add managed section marker and clean existing templates
        let managedMarker = "# --- Managed by pre-commit-configs installer ---"
        var lines = configContent.components(separatedBy: .newlines)
        var cleanedLines = [String]()
        var markerIndex = -1
        
        // Find marker and clean existing templates
        for (index, line) in lines.enumerated() {
            if line.contains(managedMarker) {
                markerIndex = index
                cleanedLines.append(line)
                break
            }
            cleanedLines.append(line)
        }
        
        // If marker wasn't found, add it
        if markerIndex == -1 {
            // Look for repos: section
            let reposLineIndex = lines.firstIndex { $0.contains("repos:") } ?? -1
            
            if reposLineIndex != -1 {
                // Add marker after the repos line and any comments
                var insertLineIndex = reposLineIndex + 1
                while insertLineIndex < lines.count && (lines[insertLineIndex].trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("#") || lines[insertLineIndex].trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                    insertLineIndex += 1
                }
                
                cleanedLines = Array(lines[0..<insertLineIndex])
                cleanedLines.append("  \(managedMarker)")
            } else {
                // No repos section found, add it with the marker
                cleanedLines.append("repos:")
                cleanedLines.append("  \(managedMarker)")
            }
        }
        
        // Collect all selected templates
        var allTemplateLines = [String]()
        
        for templateDir in templateDirs {
            let hooksTemplatesPath = "\(basePath)/hooks-templates" as NSString
            let templateDirPath = hooksTemplatesPath.appendingPathComponent(templateDir)
            let templatePath = (templateDirPath as NSString).appendingPathComponent("template.yaml")
            
            if fileManager.fileExists(atPath: templatePath) {
                // Read the template content
                let templateContent = try String(contentsOfFile: templatePath, encoding: .utf8)
                
                // Process the template content - keep everything exactly as is
                if !templateContent.isEmpty {
                    // Add an empty line between templates
                    if !allTemplateLines.isEmpty {
                        allTemplateLines.append("")
                    }
                    
                    // Add the entire template with correct indentation
                    let templateLines = templateContent.components(separatedBy: .newlines)
                    for templateLine in templateLines {
                        let trimmedLine = templateLine.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmedLine.isEmpty {
                            allTemplateLines.append("  \(templateLine)")
                        }
                    }
                    
                    print("✓ Processed template from \(templateDir)")
                }
            } else {
                print("⚠️ Template file not found: \(templatePath)")
            }
        }
        
        // Add an empty line after the marker for spacing
        if !allTemplateLines.isEmpty {
            cleanedLines.append("")
            cleanedLines.append(contentsOf: allTemplateLines)
        }
        
        // Write updated config
        configContent = cleanedLines.joined(separator: "\n")
        try configContent.write(toFile: configPath, atomically: true, encoding: .utf8)
        
        print("✓ Updated config file with \(templateDirs.count) selected templates")
        
        // Read and display the result to verify
        let resultContent = try String(contentsOfFile: configPath, encoding: .utf8)
        print("\nFinal config file content:")
        print(resultContent)
    }
}

// Run the test
print("\nTesting with multiple templates: \(testTemplates.joined(separator: ", "))")
do {
    let handler = MultipleTemplatesHandler(basePath: basePath)
    try handler.addTemplatesToConfig(templateDirs: testTemplates, configPath: configPath)
    
    // Verify all templates were added
    let finalContent = try String(contentsOfFile: configPath, encoding: .utf8)
    var success = true
    
    for template in testTemplates {
        if finalContent.contains("# \(template.prefix(1).uppercased() + template.dropFirst()) Hook") || 
           finalContent.contains("repo: https://github.com/") && finalContent.contains(template) {
            print("✓ Found template: \(template)")
        } else {
            print("❌ Missing template: \(template)")
            success = false
        }
    }
    
    if success {
        print("\n✅ TEST PASSED: All templates were correctly added to the config file!")
    } else {
        print("\n❌ TEST FAILED: Some templates are missing from the config file.")
    }
} catch {
    print("Error: \(error)")
}
