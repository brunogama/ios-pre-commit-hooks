#!/usr/bin/env swift

import Foundation

print("Pre-commit-configs Installer Patch")
print("=================================")

// Paths
let basePath = "/Users/bruno/Developer/pre-commit-configs"
let installerSourcePath = "\(basePath)/Sources/Utils/InstallerService.swift"
let patchPath = "\(basePath)/Sources/Utils/YAMLPatchInstaller.swift"

// Get method code from YAMLPatchInstaller
let patchContent = try String(contentsOfFile: patchPath, encoding: .utf8)

// Read installer service code
let installerContent = try String(contentsOfFile: installerSourcePath, encoding: .utf8)

// Create a temporary backup
let backupPath = "\(installerSourcePath).bak"
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
} else {
    print("⚠️ Could not find updateConfigFileWithTemplates method in the source file")
}

print("Installation complete. Run ./install.swift to use the patched installer.")
print("To revert, use: mv \(backupPath) \(installerSourcePath)")
