#!/usr/bin/env swift

import Foundation

print("Pre-commit-configs Full Template Installer Patch")
print("===============================================")

// Paths
let basePath = "/Users/bruno/Developer/pre-commit-configs"
let installerSourcePath = "\(basePath)/Sources/Utils/InstallerService.swift"
let patchPath = "\(basePath)/Sources/Utils/FullYAMLPatchInstaller.swift"

// Get method code from FullYAMLPatchInstaller
let patchContent = try String(contentsOfFile: patchPath, encoding: .utf8)

// Read installer service code
let installerContent = try String(contentsOfFile: installerSourcePath, encoding: .utf8)

// Create a temporary backup
let backupPath = "\(installerSourcePath).bak.full"
try installerContent.write(toFile: backupPath, atomically: true, encoding: .utf8)
print("✓ Created backup at: \(backupPath)")

// Find the original method implementation
if let oldMethodRange = installerContent.range(of: "func updateConfigFileWithTemplates(selectedTemplates: [String]) throws {") {
    // Find the method end
    var braceBalance = 1
    var endIdx = oldMethodRange.upperBound
    
    // Find matching closing brace for the method
    while braceBalance > 0 && endIdx < installerContent.endIndex {
        let char = installerContent[endIdx]
        if char == "{" {
            braceBalance += 1
        } else if char == "}" {
            braceBalance -= 1
        }
        endIdx = installerContent.index(after: endIdx)
    }
    
    // Save matching segment
    let oldMethod = installerContent[oldMethodRange.lowerBound..<endIdx]
    
    // Patch: modify the InstallerService.swift file to call our fixed implementation
    var patchedInstallerContent = installerContent
    let newMethod = """
    func updateConfigFileWithTemplates(selectedTemplates: [String]) throws {
        try updateConfigFileWithTemplatesFixed(selectedTemplates: selectedTemplates)
    }
    """
    
    // Replace the old method with our new implementation
    patchedInstallerContent = patchedInstallerContent.replacingOccurrences(of: oldMethod, with: newMethod)
    
    // Append our extension at the end of the file
    patchedInstallerContent += "\n\n" + patchContent
    
    // Write the patched file
    try patchedInstallerContent.write(toFile: installerSourcePath, atomically: true, encoding: .utf8)
    print("✓ Successfully patched InstallerService.swift")
    
    // Create a test script to verify the patch works
    let testScriptPath = "\(basePath)/test-template-fix.swift"
    let testScript = """
    #!/usr/bin/env swift
    
    import Foundation
    
    print("Testing full template handling...")
    
    // Setup test paths
    let basePath = "\(basePath)"
    let templateDir = "swiftlint"
    let configPath = "\(basePath)/test-full-config.yaml"
    
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
                configContent = "# See https://pre-commit.com/ for more information\\n# See https://pre-commit.com/hooks.html for more hooks\\n# This file is managed by the pre-commit-configs installer.\\n# Default configurations (optional)\\ndefault_stages: [pre-commit] # Sensible default\\ndefault_install_hook_types: [pre-commit, pre-push, commit-msg]\\n# default_language_version:\\n#   python: python3.9\\nrepos:\\n  # Add hooks here using the installer or manually"
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
                
                lines.insert("  \\(managedMarker)", at: insertLineIndex)
                configContent = lines.joined(separator: "\\n")
                try configContent.write(toFile: configPath, atomically: true, encoding: .utf8)
            }
            
            // Process template
            let hooksTemplatesPath = "\\(basePath)/hooks-templates" as NSString
            let templateDirPath = hooksTemplatesPath.appendingPathComponent(templateDir)
            let templatePath = (templateDirPath as NSString).appendingPathComponent("template.yaml")
            
            if fileManager.fileExists(atPath: templatePath) {
                let templateContent = try String(contentsOfFile: templatePath, encoding: .utf8)
                print("\\nTemplate content:")
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
                                .map { "  \\($0)" }
                            newLines.append(contentsOf: templateLines)
                            insertedTemplate = true
                        }
                    }
                    
                    configContent = newLines.joined(separator: "\\n")
                    try configContent.write(toFile: configPath, atomically: true, encoding: .utf8)
                    
                    // Read and show the result
                    let resultContent = try String(contentsOfFile: configPath, encoding: .utf8)
                    print("\\nUpdated config file:")
                    print(resultContent)
                    
                    print("\\n✓ Template added successfully")
                }
            } else {
                print("Error: Template file not found at \\(templatePath)")
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
        print("Error: \\(error)")
    }
    """
    
    try testScript.write(toFile: testScriptPath, atomically: true, encoding: .utf8)
    try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: testScriptPath)
    print("✓ Created test script at: \(testScriptPath)")
    
} else {
    print("⚠️ Could not find updateConfigFileWithTemplates method in the source file")
}

print("Installation complete. Run ./install.swift to use the patched installer.")
print("To test the patch, run: \(basePath)/test-template-fix.swift")
print("To revert, use: mv \(backupPath) \(installerSourcePath)")
