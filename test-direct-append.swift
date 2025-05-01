#!/usr/bin/env swift

import Foundation

print("Testing Direct Template Append")
print("=============================")

// Setup test paths
let basePath = "/Users/bruno/Developer/pre-commit-configs"
let configPath = "\(basePath)/test-direct-config.yaml"

// Define test templates
let testTemplates = ["swiftlint", "swiftformat"]

// Clean up any existing test file
let fileManager = FileManager.default
if fileManager.fileExists(atPath: configPath) {
    try fileManager.removeItem(atPath: configPath)
    print("✓ Removed existing test config file")
}

// Create a class to directly append templates
class DirectTemplateAppender {
    let fileManager = FileManager.default
    let basePath: String
    
    init(basePath: String) {
        self.basePath = basePath
    }
    
    func appendTemplatesToConfig(templateDirs: [String], configPath: String) throws {
        // Create initial config
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
        
        try defaultConfig.write(toFile: configPath, atomically: true, encoding: .utf8)
        print("✓ Created initial config file")
        
        // Prepare the template section
        var templateSection = "\n# --- BEGIN MANAGED TEMPLATES ---\n"
        
        // Read and add all template files directly
        for templateDir in templateDirs {
            let templatePath = "\(basePath)/hooks-templates/\(templateDir)/template.yaml"
            
            if fileManager.fileExists(atPath: templatePath) {
                // Read the template content without any processing
                let templateContent = try String(contentsOfFile: templatePath, encoding: .utf8)
                print("\nTemplate '\(templateDir)' content:")
                print(templateContent)
                
                // Add to template section with no modifications
                templateSection += templateContent
                
                // Add a newline if not already present
                if !templateContent.hasSuffix("\n") {
                    templateSection += "\n"
                }
                
                print("✓ Added raw template from \(templateDir)")
            } else {
                print("⚠️ Template file not found: \(templatePath)")
            }
        }
        
        // Close the template section
        templateSection += "# --- END MANAGED TEMPLATES ---\n"
        
        // Append template section to config
        var configContent = try String(contentsOfFile: configPath, encoding: .utf8)
        configContent += templateSection
        try configContent.write(toFile: configPath, atomically: true, encoding: .utf8)
        
        print("✓ Updated config file with \(templateDirs.count) raw templates")
        
        // Read and show the result
        let resultContent = try String(contentsOfFile: configPath, encoding: .utf8)
        print("\nFinal config file content:")
        print(resultContent)
    }
}

// Run the test
print("\nTesting direct append with templates: \(testTemplates.joined(separator: ", "))")
do {
    let appender = DirectTemplateAppender(basePath: basePath)
    try appender.appendTemplatesToConfig(templateDirs: testTemplates, configPath: configPath)
    
    print("\n✅ TEST PASSED: Templates were directly appended to the config file!")
} catch {
    print("Error: \(error)")
}
