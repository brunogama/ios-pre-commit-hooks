#!/usr/bin/env swift

import Foundation

// A simple test script to verify our fix works
print("Testing pre-commit-config template handling")

// Use absolute paths
let basePath = "/Users/bruno/Developer/pre-commit-configs"
let templatePath = "\(basePath)/hooks-templates/swiftlint/template.yaml"
let configPath = "\(basePath)/test-config.yaml"

do {
    // Read the template content
    let templateContent = try String(contentsOfFile: templatePath, encoding: .utf8)
    print("Template content:")
    print(templateContent)
    
    // Create a basic config file
    let defaultConfig = """
    # Default pre-commit config for testing
    repos:
    """
    try defaultConfig.write(toFile: configPath, atomically: true, encoding: .utf8)
    
    // Add the template to the config
    var configContent = try String(contentsOfFile: configPath, encoding: .utf8)
    
    // Add a marker
    let marker = "# Managed by pre-commit installer"
    configContent += "\n\n\(marker)\n"
    
    // Add the entire template content
    configContent += "\n\n" + templateContent.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Write the updated config
    try configContent.write(toFile: configPath, atomically: true, encoding: .utf8)
    
    // Read and print the result
    let result = try String(contentsOfFile: configPath, encoding: .utf8)
    print("\nUpdated config content:")
    print(result)
    
    print("\nTest completed successfully!")
} catch {
    print("Error: \(error)")
}
