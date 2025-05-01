import Foundation
import Rainbow

/// Installer service patch that properly handles MULTIPLE templates
extension InstallerService {
    
    /// Update config file with selected hook templates - fixing multiple templates issue
    func updateConfigFileWithTemplatesFixed(selectedTemplates: [String]) throws {
        let configPath = Config.configFile
        
        // Create or read existing config
        var configContent = ""
        if fileManager.fileExists(atPath: configPath) {
            configContent = try String(contentsOfFile: configPath, encoding: .utf8)
        } else {
            // Create default config if it doesn't exist
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
        
        // Add managed section marker if not present and clean any existing templates
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
        
        for templateDir in selectedTemplates {
            let hooksTemplatesPath = "hooks-templates" as NSString
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
                    
                    if verbose {
                        print("✓ Processed template from \(templateDir)".green)
                    }
                }
            } else if verbose {
                print("⚠️ Template file not found: \(templatePath)".yellow)
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
        
        if verbose {
            print("✓ Updated config file with \(selectedTemplates.count) selected templates".green)
        }
    }
}
