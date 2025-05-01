#!/usr/bin/swift

import Foundation
import Darwin.POSIX

// MARK: - Array Extension for Safe Access
extension Array {
    func get(index: Int) -> Element? {
        guard index >= 0, index < count else { return nil }
        return self[index]
    }
}

// MARK: - Configuration
struct Config {
    static let repoURL = "https://github.com/brunogama/pre-commit-configs"
    static let branch = "main"
    static let archiveURL = "\(repoURL)/archive/refs/heads/\(branch).tar.gz"
    static let configFile = ".pre-commit-config.yaml"
    static let scriptsDir = "scripts"

    // Standard content blocks for the config file
    static let standardHeader = """
# See https://pre-commit.com/ for more information
# See https://pre-commit.com/hooks.html for more hooks
# This file is managed by the pre-commit-configs installer.
"""

    static let standardDefaults = """
# Default configurations (optional)
default_stages: [pre-commit] # Sensible default
default_install_hook_types: [pre-commit, pre-push, commit-msg]
# default_language_version:
#   python: python3.9
"""

    static let managedHookMarker = "# --- Managed by pre-commit-configs installer ---"
}

// MARK: - Hook Definitions
struct Hook {
    let id: String
    let repo: String
    let rev: String
    let description: String
    let details: String
}

struct HookGroup {
    let name: String
    let description: String
    let hooks: [Hook]
}

let availableHooks: [HookGroup] = [
    HookGroup(
        name: "File Formatting",
        description: "Hooks for maintaining consistent file formatting",
        hooks: [
            Hook(
                id: "check-yaml",
                repo: "https://github.com/pre-commit/pre-commit-hooks",
                rev: "v4.5.0",
                description: "Checks YAML files for parseable syntax",
                details: "Ensures all your YAML files are syntactically correct"
            ),
            Hook(
                id: "check-json",
                repo: "https://github.com/pre-commit/pre-commit-hooks",
                rev: "v4.5.0",
                description: "Checks JSON files for parseable syntax",
                details: "Validates JSON files and ensures they are well-formed"
            ),
            Hook(
                id: "pretty-format-json",
                repo: "https://github.com/pre-commit/pre-commit-hooks",
                rev: "v4.5.0",
                description: "Formats JSON files",
                details: "Automatically formats JSON files with consistent indentation and spacing"
            )
        ]
    ),
    HookGroup(
        name: "Code Quality",
        description: "Hooks for maintaining code quality and standards",
        hooks: [
            Hook(
                id: "trailing-whitespace",
                repo: "https://github.com/pre-commit/pre-commit-hooks",
                rev: "v4.5.0",
                description: "Removes trailing whitespace",
                details: "Trims trailing whitespace from all lines in files"
            ),
            Hook(
                id: "end-of-file-fixer",
                repo: "https://github.com/pre-commit/pre-commit-hooks",
                rev: "v4.5.0",
                description: "Ensures files end with a newline",
                details: "Makes sure all text files end with exactly one newline"
            ),
            Hook(
                id: "check-merge-conflict",
                repo: "https://github.com/pre-commit/pre-commit-hooks",
                rev: "v4.5.0",
                description: "Checks for merge conflict markers",
                details: "Prevents committing files with git merge conflict markers"
            )
        ]
    ),
    HookGroup(
        name: "Swift Specific",
        description: "Hooks specifically for Swift development",
        hooks: [
            Hook(
                id: "swiftlint",
                repo: "https://github.com/realm/SwiftLint",
                rev: "0.54.0",
                description: "Swift style and conventions linter",
                details: "Enforces Swift style and conventions defined in your .swiftlint.yml"
            ),
            Hook(
                id: "swiftformat",
                repo: "https://github.com/nicklockwood/SwiftFormat",
                rev: "0.53.5",
                description: "Swift code formatter",
                details: "Automatically formats Swift code according to a consistent style"
            )
        ]
    ),
    HookGroup(
        name: "iOS Specific",
        description: "Hooks for iOS development workflow",
        hooks: [
            Hook(
                id: "accessibility-check",
                repo: "local",
                rev: "local",
                description: "Checks for accessibility implementation",
                details: "Ensures UI elements have proper accessibility labels and hints"
            ),
            Hook(
                id: "xcode-project-check",
                repo: "local",
                rev: "local",
                description: "Validates Xcode project settings",
                details: "Checks for common issues in Xcode project configuration"
            ),
            Hook(
                id: "unused-assets-check",
                repo: "local",
                rev: "local",
                description: "Finds unused assets",
                details: "Identifies images and other assets that aren't referenced in code"
            )
        ]
    )
]

// MARK: - Terminal Colors and Formatting
enum Term {
    static let red = "\u{001B}[0;31m"
    static let green = "\u{001B}[0;32m"
    static let blue = "\u{001B}[0;34m"
    static let yellow = "\u{001B}[1;33m"
    static let reset = "\u{001B}[0m"
    
    static func colored(_ text: String, _ color: String) -> String {
        "\(color)\(text)\(reset)"
    }
    
    static func clearLine() {
        print("\u{001B}[2K\r", terminator: "")
    }
    
    static func moveCursorUp(_ lines: Int = 1) {
        print("\u{001B}[\(lines)A", terminator: "")
    }
    
    static func progressBar(progress: Double, width: Int = 40) -> String {
        let filled = Int(progress * Double(width))
        let empty = width - filled
        let bar = String(repeating: "█", count: filled) + String(repeating: "░", count: empty)
        return "[\(bar)] \(Int(progress * 100))%"
    }
    
    static func confirm(_ message: String) -> Bool {
        print(Term.colored("\n\(message) (y/n): ", Term.yellow), terminator: "")
        fflush(stdout)
        while true {
            if let key = MenuCursor.readKey() {
                if key.lowercased() == "y" {
                    print("y") // Echo confirmation
                    return true
                } else if key.lowercased() == "n" {
                    print("n") // Echo cancellation
                    return false
                }
            }
            // Ignore other keys
        }
    }
}

// MARK: - UI Components
class TerminalUI {
    static func showWelcome() {
        print(Term.colored("""
        ╔════════════════════════════════════════════╗
        ║     Pre-commit Hooks Installer (Swift)     ║
        ╚════════════════════════════════════════════╝
        """, Term.blue))
        print("\nThis will set up pre-commit hooks and necessary scripts for your project.\n")
    }
    
    static func confirm(_ message: String) -> Bool {
        Term.confirm(message)
    }
    
    static func showProgress(title: String, progress: Double, message: String) {
        Term.clearLine()
        Term.moveCursorUp()
        print("\(title):")
        print("\(Term.progressBar(progress: progress)) \(message)")
    }
    
    static func showSuccess(_ message: String) {
        print(Term.colored("✓ \(message)", Term.green))
    }
    
    static func showError(_ message: String) {
        print(Term.colored("✗ \(message)", Term.red))
    }
    
    static func showWarning(_ message: String) {
        print(Term.colored("! \(message)", Term.yellow))
    }
}

// MARK: - Menu System
enum MenuOption {
    case configureHooks
    case installSelected
    case exit
    
    static var all: [(MenuOption, String, String)] {
        [
            (.configureHooks, "Configure Hooks", "Select and configure pre-commit hooks"),
            (.installSelected, "Install Selected Items", "Install all selected hooks and dependent scripts"),
            (.exit, "Exit", "Exit the installer")
        ]
    }
}

// MARK: - Installer UI
class InstallerUI {
    private var selectedHooks: Set<String> = []
    private let installer: Installer
    
    init(installer: Installer) {
        self.installer = installer
    }
    
    func mainMenu() {
        var currentSelection = 0
        let options = MenuOption.all
        
        while true {
            MenuCursor.clearScreen()
            
            // Show title and introduction
            print(Term.colored("Pre-commit Hooks Installer", Term.blue))
            print("Selected: \(selectedHooks.count) hooks\n")
            
            // Display menu items
            for (index, option) in options.enumerated() {
                let cursor = index == currentSelection ? Term.colored(">", Term.green) : " "
                let displayCount = option.0 == .configureHooks ? "(selected: \(selectedHooks.count))" : ""
                print("\(cursor) \(option.1) \(displayCount)")
            }
            
            // Instructions
            print("\nUse up/down arrows to navigate, Enter to select")
            fflush(stdout)
            
            // Process key input
            if let key = MenuCursor.readKey() {
                switch key {
                case MenuCursor.up:
                    if currentSelection > 0 {
                        currentSelection -= 1
                    }
                case MenuCursor.down:
                    if currentSelection < options.count - 1 {
                        currentSelection += 1
                    }
                case MenuCursor.enter:
                    // Process selection
                    let chosenOption = options[currentSelection].0
                    MenuCursor.clearScreen()
                    
                    switch chosenOption {
                    case .configureHooks:
                        configureHooks()
                    case .installSelected:
                        if installSelected() { return } // Exit if installation successful
                    case .exit:
                        if confirmExit() { return } // Exit if confirmed
                    }
                    
                // Simple numeric selection
                case "1": currentSelection = 0 // Configure Hooks
                case "2": currentSelection = 1 // Install Selected Items
                case "3": currentSelection = 2 // Exit
                default:
                    // Ignore other keys
                    break
                }
            }
            
            // Short sleep to prevent CPU hogging
            usleep(10000)
        }
    }
    
    // MARK: - Hook Configuration Logic
    private func configureHooks() {
        var currentSelection = 0
        var currentSelections = selectedHooks
        
        // Build a flat, easy-to-navigate menu of all hooks
        var flattenedHooks: [(groupIndex: Int, hookIndex: Int, hook: Hook, displayText: String)] = []
        
        for (groupIndex, group) in availableHooks.enumerated() {
            // Add a "group header" item
            flattenedHooks.append((groupIndex, -1, Hook(id: "", repo: "", rev: "", description: "", details: ""), 
                                  "[\(groupIndex + 1)] \(group.name) - \(group.description)"))
            
            // Add all hooks in this group
            for (hookIndex, hook) in group.hooks.enumerated() {
                flattenedHooks.append((groupIndex, hookIndex, hook, hook.id))
            }
        }
        
        while true {
            MenuCursor.clearScreen()
            
            print(Term.colored("Hook Configuration", Term.blue))
            print("Selected: \(currentSelections.count) hooks\n")
            
            // Display menu items
            for (index, item) in flattenedHooks.enumerated() {
                let isHeader = item.hookIndex == -1
                let isSelected = !isHeader && currentSelections.contains(item.hook.id)
                let cursor = index == currentSelection ? Term.colored(">", Term.green) : " "
                
                if isHeader {
                    // This is a group header
                    print("\(cursor) \(Term.colored(item.displayText, Term.yellow))")
                } else {
                    // This is a selectable hook
                    let checkbox = isSelected ? "[✓]" : "[ ]"
                    print("\(cursor) \(checkbox) \(item.displayText)")
                    // If this is the current selection, show the description
                    if index == currentSelection {
                        print("       \(item.hook.description)")
                        print("       \(item.hook.details)")
                    }
                }
            }
            
            print("\nUse up/down arrows to navigate, Space to toggle selection, Enter to confirm, Esc to go back")
            fflush(stdout)
            
            // Process key input
            if let key = MenuCursor.readKey() {
                switch key {
                case MenuCursor.up:
                    if currentSelection > 0 {
                        currentSelection -= 1
                    }
                case MenuCursor.down:
                    if currentSelection < flattenedHooks.count - 1 {
                        currentSelection += 1
                    }
                case MenuCursor.space:
                    // Toggle selection for current item if not a header
                    let currentItem = flattenedHooks[currentSelection]
                    if currentItem.hookIndex != -1 { // Not a header
                        let hookId = currentItem.hook.id
                        if currentSelections.contains(hookId) {
                            currentSelections.remove(hookId)
                        } else {
                            currentSelections.insert(hookId)
                        }
                    }
                case MenuCursor.enter:
                    // Save selections and return
                    selectedHooks = currentSelections
                    return
                case MenuCursor.escape, "b", "B":
                    // Cancel and return (discard changes)
                    return
                default:
                    // Ignore other keys
                    break
                }
            }
            
            // Short sleep to prevent CPU hogging
            usleep(10000)
        }
    }
    
    // MARK: - Installation and Confirmation
    private func showSelectedForConfirmation(requiredScripts: [String]) {
        // MenuCursor.clearScreen() // Don't clear screen, show as part of install flow
        print(Term.colored("\n--- Review Selections ---", Term.blue))

        if selectedHooks.isEmpty {
            print("\nNo hooks selected")
        } else {
            print(Term.colored("\nSelected Hooks:", Term.yellow))
            // Keep original grouping for clarity
            for group in availableHooks {
                let groupHooks = group.hooks.filter { selectedHooks.contains($0.id) }.sorted { $0.id < $1.id }
                 if !groupHooks.isEmpty {
                    print("\n  " + Term.colored(group.name, Term.blue))
                    for hook in groupHooks {
                        print("    • \(hook.id) (\(Term.colored(hook.description, Term.yellow)))")
                    }
                }
            }
        }

        // Show required scripts instead
        if requiredScripts.isEmpty {
            print("\nNo additional scripts required by selected hooks")
        } else {
            print(Term.colored("\nRequired Scripts (will be installed):", Term.yellow))
            if let templates = try? installer.getAvailableTemplates() {
                 let sortedRequiredScripts = requiredScripts.sorted()
                for scriptName in sortedRequiredScripts {
                     // Extract just the filename for lookup
                     let filename = (scriptName as NSString).lastPathComponent
                     if let template = templates.first(where: { $0.0 == filename }) {
                         print("    • \(template.0) (\(Term.colored(template.1, Term.yellow)))")
                     } else {
                         print("    • \(filename)") // Fallback if description not found
                     }
                }
            } else {
                 // Print sorted names if templates couldn't be re-fetched
                 requiredScripts.sorted().forEach { print("    • \($0)") }
            }
        }
        
        print("\n" + String(repeating: "-", count: 25)) // Add separator
    }
    
    private func installSelected() -> Bool {
        MenuCursor.clearScreen()

        // Determine required scripts based on selected hooks
        var requiredScripts: Set<String> = []
        for hookId in selectedHooks {
            if let hook = availableHooks.flatMap({ $0.hooks }).first(where: { $0.id == hookId }), hook.repo == "local" {
                 // Derive script path from hook definition (assuming 'entry' holds the relative path)
                 // This logic matches the one in `updateConfigFile`
                 var scriptPath = ""
                 switch hook.id {
                 case "accessibility-check":
                     scriptPath = "\(Config.scriptsDir)/accessibility-check.sh"
                 case "xcode-project-check":
                     scriptPath = "\(Config.scriptsDir)/check-xcode-dangling-refs.sh" 
                 case "unused-assets-check":
                      scriptPath = "\(Config.scriptsDir)/check-unused-assets.sh"
                 default:
                     scriptPath = "\(Config.scriptsDir)/\(hookId).sh"
                 }
                 requiredScripts.insert(scriptPath) // Insert the full path
            }
        }
        let requiredScriptList = Array(requiredScripts)
        let requiredScriptFilenames = requiredScriptList.map { ($0 as NSString).lastPathComponent } // Get just filenames for setupScripts

        if selectedHooks.isEmpty { // Check hooks only now
            TerminalUI.showWarning("Nothing selected to install!")
            print("\nPress Enter to continue...")
            _ = MenuCursor.waitForEnter()
            return false
        }

        // Show what will be installed before confirming
        showSelectedForConfirmation(requiredScripts: requiredScriptList)

        print(Term.colored("\nReady to install:", Term.blue)) // Add newline for spacing
        print("  • \(selectedHooks.count) hooks")
        print("  • \(requiredScriptFilenames.count) required scripts")

        if !TerminalUI.confirm("Proceed with installation?") {
            return false // User cancelled
        }

        // --- Installation Process ---
        MenuCursor.clearScreen()
        print(Term.colored("Installing...", Term.blue))
        var success = true
        var errorMessage = ""

        do {
            // 1. Create/Verify Config File (ensures it exists before update)
            try installer.createConfigFileIfNeeded()
            TerminalUI.showSuccess("Configuration file verified/created.")

            // 2. Setup Required Scripts (based on selected hooks)
            if !requiredScriptFilenames.isEmpty {
                print(Term.colored("\nSetting up required scripts...", Term.yellow))
                try installer.setupScripts(requiredScriptFilenames) 
                TerminalUI.showSuccess("Scripts installed.")
            } else {
                 print("\nSkipping script setup (no scripts required by selected hooks).")
            }

            // 3. Update Config File with Selected Hooks
            print(Term.colored("\nUpdating configuration file with selected hooks...", Term.yellow))
            try installer.updateConfigFile(selectedHookIds: selectedHooks)
            TerminalUI.showSuccess("Configuration file updated.")

            // 4. Install Hooks via pre-commit install (immediately after config update)
            print(Term.colored("\nRunning 'pre-commit install' to set up hooks defined in config...", Term.yellow))
            // Pass --install-hooks to ensure the hooks are activated based on the updated config
            try installer.installHooks(forceInstall: true) 
            TerminalUI.showSuccess("Pre-commit hooks installed/updated.")

            // --- Final Success Message --- 
            print(Term.colored("\n✨ Installation completed successfully!", Term.green))
            print("""

            To verify the installation, run:
            pre-commit run --all-files

            Configuration: \(Config.configFile)
            Scripts: \(Config.scriptsDir)/
            Make sure to commit these changes to your repository.
            """)

        } catch {
            success = false
            errorMessage = error.localizedDescription
            TerminalUI.showError("\nInstallation failed: \(errorMessage)")
        }

        print("\nPress Enter to continue...")
        _ = MenuCursor.waitForEnter()
        return success
    }
    
    private func confirmExit() -> Bool {
        if selectedHooks.isEmpty {
            return true // Nothing selected, safe to exit
        }

        MenuCursor.clearScreen()
        print(Term.colored("You have uninstalled selections:", Term.yellow))
        print("  • \(selectedHooks.count) hooks")

        return TerminalUI.confirm("Are you sure you want to exit without installing?")
    }
}

// MARK: - Installer Logic
class Installer {
    private let fileManager = FileManager.default
    private let tempDir: String
    
    init() throws {
        tempDir = (NSTemporaryDirectory() as NSString).appendingPathComponent(UUID().uuidString)
        try fileManager.createDirectory(atPath: tempDir, withIntermediateDirectories: true)
        TerminalUI.showSuccess("Temporary directory created at \(tempDir)")
    }
    
    deinit {
        TerminalUI.showWarning("Cleaning up temporary directory: \(tempDir)")
        try? fileManager.removeItem(atPath: tempDir)
    }
    
    func verifyDependencies() throws {
        let requiredCommands = ["grep", "find", "xargs", "git", "pre-commit", "tar"] // Added tar
        var missingDeps: [String] = []
        
        for cmd in requiredCommands {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
            process.arguments = [cmd]
            let pipe = Pipe()
            process.standardOutput = pipe // Suppress output
            process.standardError = pipe // Suppress output
            
            do {
                try process.run()
                process.waitUntilExit()
                if process.terminationStatus != 0 {
                    missingDeps.append(cmd)
                }
            } catch {
                missingDeps.append(cmd) // Assume missing if 'which' fails
            }
        }
        
        // Check Xcode tools on macOS
        #if os(macOS)
        let xcodeSelect = Process()
        xcodeSelect.executableURL = URL(fileURLWithPath: "/usr/bin/xcode-select")
        xcodeSelect.arguments = ["-p"]
        let xcodePipe = Pipe()
        xcodeSelect.standardOutput = xcodePipe // Suppress output
        xcodeSelect.standardError = xcodePipe // Suppress output
        
        do {
            try xcodeSelect.run()
            xcodeSelect.waitUntilExit()
            if xcodeSelect.terminationStatus != 0 {
                missingDeps.append("xcode-select (Xcode Command Line Tools)")
            }
        } catch {
            missingDeps.append("xcode-select (Xcode Command Line Tools)")
        }
        #endif
        
        if !missingDeps.isEmpty {
            throw InstallerError.missingDependencies(missingDeps)
        }
    }
    
    func downloadRepository() throws {
        let url = URL(string: Config.archiveURL)!
        let destinationURL = URL(fileURLWithPath: tempDir).appendingPathComponent("repo.tar.gz")
        TerminalUI.showProgress(title: "Downloading Repository", progress: 0.0, message: "Starting download...")

        var observation: NSKeyValueObservation?
        let semaphore = DispatchSemaphore(value: 0)
        var downloadError: Error?

        let downloadTask = URLSession.shared.downloadTask(with: url) { location, response, error in
            defer { semaphore.signal() } // Signal completion regardless of outcome

            if let error = error {
                downloadError = InstallerError.downloadFailed("Network error: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                downloadError = InstallerError.downloadFailed("HTTP error: Status code \(statusCode)")
                return
            }
            guard let location = location else {
                downloadError = InstallerError.downloadFailed("Download location is nil")
                return
            }

            do {
                // Ensure tempDir exists before moving
                try self.fileManager.createDirectory(atPath: self.tempDir, withIntermediateDirectories: true)
                // Remove existing file if present, otherwise moveItem fails
                if self.fileManager.fileExists(atPath: destinationURL.path) {
                     try self.fileManager.removeItem(at: destinationURL)
                }
                try self.fileManager.moveItem(at: location, to: destinationURL)
            } catch {
                downloadError = InstallerError.downloadFailed("Failed to save archive: \(error.localizedDescription)")
            }
        }

        // Observe progress
        observation = downloadTask.progress.observe(\.fractionCompleted) { progress, _ in
            DispatchQueue.main.async { // Update UI on main thread
                TerminalUI.showProgress(
                    title: "Downloading Repository",
                    progress: progress.fractionCompleted,
                    message: String(format: "%.1f MB / %.1f MB", progress.completedUnitCount / 1_000_000, progress.totalUnitCount / 1_000_000)
                )
            }
        }

        downloadTask.resume()
        semaphore.wait() // Wait for download completion or error
        observation?.invalidate() // Stop observing

        if let downloadError = downloadError {
             TerminalUI.showProgress(title: "Downloading Repository", progress: 0.0, message: "Download failed.")
            throw downloadError
        }

        TerminalUI.showProgress(title: "Downloading Repository", progress: 1.0, message: "Download complete. Extracting...")

        // Extract archive
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/tar")
        // Ensure flags are correct for gzipped tarball
        process.arguments = ["xzf", destinationURL.path, "-C", tempDir, "--strip-components=1"]
        let pipe = Pipe()
        process.standardOutput = pipe // Capture output/errors if needed
        process.standardError = pipe

        do {
           try process.run()
           process.waitUntilExit()

           if process.terminationStatus != 0 {
               let errorData = pipe.fileHandleForReading.readDataToEndOfFile()
               let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown extraction error"
               throw InstallerError.extractionFailed(errorString)
           }
        } catch {
            throw InstallerError.extractionFailed("Failed to run tar command: \(error.localizedDescription)")
        }
        TerminalUI.showProgress(title: "Repository Setup", progress: 1.0, message: "Extraction complete.")
    }
    
    func getAvailableTemplates() throws -> [(String, String)] {
        let scriptsSourceDir = (tempDir as NSString).appendingPathComponent(Config.scriptsDir)
        guard fileManager.fileExists(atPath: scriptsSourceDir) else {
            TerminalUI.showWarning("Scripts directory not found in downloaded repository: \(scriptsSourceDir)")
            return [] // No templates available if directory doesn't exist
        }

        do {
            let contents = try fileManager.contentsOfDirectory(atPath: scriptsSourceDir)
            // Filter for .sh files and map to (filename, description)
            let templates = contents.filter { $0.hasSuffix(".sh") }.map { filename in
                (filename, getTemplateDescription(filename: filename, inDirectory: scriptsSourceDir))
            }.sorted { $0.0 < $1.0 } // Sort alphabetically by filename

            return templates
        } catch {
            throw InstallerError.genericError("Failed to list script templates in \(scriptsSourceDir): \(error.localizedDescription)")
        }
    }
    
    private func getTemplateDescription(filename: String, inDirectory: String) -> String {
        let path = (inDirectory as NSString).appendingPathComponent(filename)
        guard let contents = try? String(contentsOfFile: path, encoding: .utf8) else {
            return "No description available (cannot read file)"
        }

        // Try to find the first comment line starting with '#' but not '#!' as description
        let lines = contents.components(separatedBy: .newlines)
        if let descriptionLine = lines.first(where: { $0.trimmingCharacters(in: .whitespaces).hasPrefix("#") && !$0.trimmingCharacters(in: .whitespaces).hasPrefix("#!") }) {
             return descriptionLine.trimmingCharacters(in: CharacterSet(charactersIn: "# ")) // Cleaned description
        }

        // Fallback descriptions (optional)
         // switch filename {
         // case "some-specific-script.sh": return "Specific fallback description"
         // default: break
         // }

        return "No description comment found" // Default if no suitable comment line
    }
    
    func setupScripts(_ selectedTemplates: [String]) throws {
        let scriptsSourceDir = (tempDir as NSString).appendingPathComponent(Config.scriptsDir)
        let scriptsDestDir = Config.scriptsDir // Relative to current working directory

        guard fileManager.fileExists(atPath: scriptsSourceDir) else {
            throw InstallerError.genericError("Script source directory not found: \(scriptsSourceDir)")
        }

        // Ensure destination directory exists
        try fileManager.createDirectory(atPath: scriptsDestDir, withIntermediateDirectories: true)

        for template in selectedTemplates {
            let sourcePath = (scriptsSourceDir as NSString).appendingPathComponent(template)
            let destinationPath = (scriptsDestDir as NSString).appendingPathComponent(template)

            guard fileManager.fileExists(atPath: sourcePath) else {
                TerminalUI.showWarning("Script template file not found, skipping: \(template)")
                continue // Skip if a selected template file doesn't actually exist
            }

            do {
                // Remove existing destination file first to avoid copy errors
                if fileManager.fileExists(atPath: destinationPath) {
                    try fileManager.removeItem(atPath: destinationPath)
                }
                // Copy the script
                try fileManager.copyItem(atPath: sourcePath, toPath: destinationPath)
                // Make it executable (owner + group + others can read/execute)
                try fileManager.setAttributes([.posixPermissions: 0o755], ofItemAtPath: destinationPath)
                TerminalUI.showSuccess("Installed script: \(template)")
            } catch {
                throw InstallerError.genericError("Failed to install script \(template): \(error.localizedDescription)")
            }
        }
    }
    
    func updateConfigFile(selectedHookIds: Set<String>) throws {
        let configPath = Config.configFile
        
        // Ensure file exists, creating if necessary
        if !fileManager.fileExists(atPath: configPath) {
            TerminalUI.showWarning("Config file not found, creating a default one.")
            try createConfigFileIfNeeded() // This will throw if creation fails or is skipped
        }
        
        let originalContent = try String(contentsOfFile: configPath, encoding: .utf8)
        let lines = originalContent.components(separatedBy: .newlines)

        // --- Extract Existing Repos Section --- 
        var existingReposContent: [String] = []
        for (index, line) in lines.enumerated() {
            if line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "repos:") {
                // Capture from repos: onwards
                existingReposContent = Array(lines.suffix(from: index + 1))
                break
            }
        }
        
        // If repos: was not found, the existingReposContent will be empty

        // --- Construct the Required Top Section --- 
        let requiredTopSection = """
        \(Config.standardHeader)

        \(Config.standardDefaults)
        """
        
        // --- Prepare Managed Hooks Section --- 
        let repoMarker = Config.managedHookMarker
        var managedHooksAdditions = "\n" + String(repeating: " ", count: 2) + repoMarker + "\n" // Add marker

        // Group selected hooks by repo (same logic as before)
        var hooksByRepo: [String: [(id: String, rev: String)]] = [:]
        var localHooks: [(id: String, name: String, entry: String, language: String, files: String)] = []
        
        for hookId in selectedHookIds {
             if let hook = availableHooks.flatMap({ $0.hooks }).first(where: { $0.id == hookId }) {
                 if hook.repo == "local" {
                      var entry = ""
                      var files = ""
                      let name = hook.description
                      let language = "script"
                      switch hook.id {
                      case "accessibility-check":
                          entry = "\(Config.scriptsDir)/accessibility-check.sh"
                          files = "\\.swift$"
                      case "xcode-project-check":
                          entry = "\(Config.scriptsDir)/check-xcode-dangling-refs.sh"
                          files = "\\.pbxproj$"
                      case "unused-assets-check":
                           entry = "\(Config.scriptsDir)/check-unused-assets.sh"
                           files = "\\.(swift|storyboard|xib)$"
                      default:
                          entry = "\(Config.scriptsDir)/\(hookId).sh"
                          files = ""
                      }
                      localHooks.append((id: hook.id, name: name, entry: entry, language: language, files: files))
                 } else {
                     if hooksByRepo[hook.repo] == nil {
                         hooksByRepo[hook.repo] = []
                     }
                     if !hooksByRepo[hook.repo]!.contains(where: { $0.id == hook.id && $0.rev == hook.rev }) {
                         hooksByRepo[hook.repo]!.append((id: hook.id, rev: hook.rev))
                     }
                 }
             }
         }

        // Append remote hooks to additions string
        for (repo, hooks) in hooksByRepo.sorted(by: { $0.key < $1.key }) {
            if let rev = hooks.first?.rev {
                managedHooksAdditions += "  - repo: \(repo)\n"
                managedHooksAdditions += "    rev: \(rev)\n"
                managedHooksAdditions += "    hooks:\n"
                for hook in hooks.sorted(by: { $0.id < $1.id }) {
                    managedHooksAdditions += "      - id: \(hook.id)\n"
                 }
             }
        }

        // Append local hooks to additions string
         if !localHooks.isEmpty {
             managedHooksAdditions += "  - repo: local\n"
             managedHooksAdditions += "    hooks:\n"
             for hook in localHooks.sorted(by: { $0.id < $1.id }) {
                 managedHooksAdditions += "      - id: \(hook.id)\n"
                 managedHooksAdditions += "        name: \"\(hook.name)\"\n"
                 managedHooksAdditions += "        entry: \(hook.entry)\n"
                 managedHooksAdditions += "        language: \(hook.language)\n"
                 if !hook.files.isEmpty {
                     managedHooksAdditions += "        files: \(hook.files)\n"
                 }
                 managedHooksAdditions += "        stages: [pre-commit]\n"
             }
         }
         
         // Only add the marker and hooks if hooks were actually selected
         if selectedHookIds.isEmpty {
             managedHooksAdditions = "" // Don't add marker if no hooks selected
         }

        // --- Combine and Write --- 
        // Construct the final content: Required Top -> repos: -> Existing Hooks -> Managed Hooks
        let finalContent = requiredTopSection + "\nrepos:\n" + 
                           existingReposContent.joined(separator: "\n") + 
                           managedHooksAdditions

        // Write the modified content back
        try finalContent.write(toFile: configPath, atomically: true, encoding: .utf8)
    }
    
    func installHooks(forceInstall: Bool = false) throws {
        let progressMessage = "Running pre-commit install..."
        TerminalUI.showProgress(title: "Installing Hooks", progress: 0.0, message: progressMessage)
        
        var arguments = ["pre-commit", "install"]
        if forceInstall {
            arguments.append("--install-hooks")
        }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = arguments

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        do {
            try process.run()
            process.waitUntilExit()
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let outputString = String(data: outputData, encoding: .utf8) ?? ""
            let errorString = String(data: errorData, encoding: .utf8) ?? ""

            if process.terminationStatus == 0 {
                TerminalUI.showProgress(title: "Installing Hooks", progress: 1.0, message: "Hooks installed successfully.")
                if !outputString.isEmpty { print("Output:\n\(outputString)") }
            } else {
                let combinedError = "pre-commit install failed (status \(process.terminationStatus)). Error output: \(errorString.isEmpty ? "None" : errorString)"
                throw InstallerError.hookInstallationFailed("general", combinedError)
            }
        } catch {
             let errorDetails = "Failed to execute pre-commit install command: \(error.localizedDescription)"
             throw InstallerError.hookInstallationFailed("general", errorDetails)
        }
    }
    
    func createConfigFileIfNeeded() throws {
        if !fileManager.fileExists(atPath: Config.configFile) {
            TerminalUI.showWarning("Configuration file \(Config.configFile) not found.")
            if TerminalUI.confirm("Create a new default .pre-commit-config.yaml file?") {
                // Combine standard header, defaults, and the repos key
                let initialContent = """
                \(Config.standardHeader)

                \(Config.standardDefaults)

                repos:
                  # Add hooks here using the installer or manually
                """
                do {
                    try initialContent.write(toFile: Config.configFile, atomically: true, encoding: .utf8)
                    TerminalUI.showSuccess("Created \(Config.configFile) with default header and structure.")
                } catch {
                    throw InstallerError.genericError("Failed to create \(Config.configFile): \(error.localizedDescription)")
                }
            } else {
                TerminalUI.showWarning("Skipping config file creation. Installation might fail if the file is required.")
                // Ensure the function doesn't proceed if creation is skipped but needed
                throw InstallerError.genericError("Config file creation skipped by user.") 
            }
        } else {
            TerminalUI.showSuccess("Configuration file \(Config.configFile) found.")
            // Update function will handle ensuring defaults in existing files
        }
    }
}

// MARK: - Error Handling
enum InstallerError: Error {
    case missingDependencies([String])
    case downloadFailed(String)
    case extractionFailed(String)
    case hookInstallationFailed(String, String)
    case genericError(String)
}

extension InstallerError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingDependencies(let deps):
            return "Missing dependencies: \(deps.joined(separator: ", ")). Please install them and try again."
        case .downloadFailed(let reason):
            return "Failed to download repository archive: \(reason)"
        case .extractionFailed(let reason):
            return "Failed to extract repository archive: \(reason)"
        case .hookInstallationFailed(let hookType, let reason):
            return "Failed to install '\(hookType)' hook: \(reason)"
        case .genericError(let message):
            return "An error occurred: \(message)"
        }
    }
}

// MARK: - Menu Cursor (Input Handling)
struct MenuCursor {
    // Key definitions
    static let up = "up"
    static let down = "down"
    static let right = "right" // Keep for future use
    static let left = "left"   // Keep for future use
    static let enter = "enter"
    static let space = "space"
    static let escape = "escape"
    static let backspace = "backspace" // Added
    static let tab = "tab"           // Added
    // Special keys (example)
    static let home = "home"
    static let end = "end"
    static let pageup = "pageup"
    static let pagedown = "pagedown"
    // Function keys (example)
    static let f1 = "f1"
    static let f2 = "f2"

    // Terminal control sequences (Constants)
    private static let ESC: UInt8 = 27
    private static let BRACKET: UInt8 = 91
    private static let O_KEY: UInt8 = 79

    // Reads a single key press, handling special keys and escape sequences.
    static func readKey() -> String? {
        guard let termios = setRawMode() else {
             print("Error: Could not set terminal to raw mode.")
             return nil
        }
        defer { restoreRawMode(originalTermios: termios) }

        var buffer = [UInt8](repeating: 0, count: 8) // Increased buffer size slightly
        let bytesRead = read(STDIN_FILENO, &buffer, buffer.count)

        guard bytesRead > 0 else {
            return nil // No input read (timeout or error)
        }

        // Debug keystroke
        // print("DEBUG: Read \(bytesRead) bytes: \(Array(buffer.prefix(bytesRead)))")

        // --- Parse Input ---
        let firstByte = buffer[0]

        // 1. Handle Escape Sequences (ESC ...)
        if firstByte == ESC {
             // Check for common CSI (Control Sequence Introducer) sequences: ESC [ ...
             if bytesRead >= 3 && buffer[1] == BRACKET {
                 switch buffer[2] {
                 case 65: return up      // ESC [ A
                 case 66: return down    // ESC [ B
                 case 67: return right   // ESC [ C
                 case 68: return left    // ESC [ D
                 case 72: return home    // ESC [ H (often Home) - check if it conflicts
                 case 70: return end     // ESC [ F (often End) - check if it conflicts
                 default: 
                     // Try to debug sequence
                     if bytesRead >= 4 {
                         print("DEBUG: Unrecognized ESC sequence: \(buffer[1]) \(buffer[2]) \(buffer[3])")
                     }
                     break
                 }
                 // Check for sequences like ESC [ 1 ~ (Home), ESC [ 4 ~ (End) etc.
                 if bytesRead >= 4 && buffer[3] == 126 { // '~'
                     switch buffer[2] {
                         case 49: return home     // ESC [ 1 ~
                         case 51: return "delete" // ESC [ 3 ~ (Delete key)
                         case 52: return end      // ESC [ 4 ~
                         case 53: return pageup   // ESC [ 5 ~
                         case 54: return pagedown // ESC [ 6 ~
                         default: break
                     }
                 }
             }
             // Check for sequences like ESC O P (F1), etc.
             if bytesRead >= 3 && buffer[1] == O_KEY {
                 switch buffer[2] {
                     case 80: return f1 // ESC O P
                     case 81: return f2 // ESC O Q
                     // ... add other F keys if needed ...
                     default: break
                 }
             }
             // If it's just ESC or an unrecognized sequence
             return escape
        }

        // 2. Handle Common Single Keys
        switch firstByte {
        case 10, 13: // Enter key (LF or CR)
            return enter
        case 32: // Space key
            return space
        case 127: // Backspace key (commonly 127 on macOS/Linux)
             return backspace
         case 8: // Backspace key (sometimes 8)
             return backspace
        case 9: // Tab key
            return tab
        // Allow printable ASCII characters (numbers, letters, symbols)
         case 33...126:
             return String(bytes: [firstByte], encoding: .utf8)
        default:
            print("DEBUG: Unrecognized character code: \(firstByte)")
            return nil // Or return a special marker if needed
        }
    }

    // Helper to wait for Enter key
    static func waitForEnter() -> String? {
         while true {
             if let key = readKey(), key == enter {
                 return key
             }
             usleep(10000) // Sleep 10ms to prevent CPU hogging
             // Ignore other keys while waiting specifically for Enter
         }
    }

    // --- Terminal Mode Management ---
    private static var isRawModeSet = false // Prevent nested raw mode calls
    private static var savedTermios: termios? = nil // Save between calls

    // Sets terminal to raw mode (no echo, no line buffering)
    private static func setRawMode() -> termios? {
         // If already in raw mode, return saved settings
         if isRawModeSet {
             return savedTermios
         }

        var originalTermios = termios()
        guard tcgetattr(STDIN_FILENO, &originalTermios) == 0 else {
            perror("Error getting terminal attributes (tcgetattr)")
            return nil
        }

        var raw = originalTermios
        // Configure raw mode:
        // Input flags: no break signal, no CR to NL, no parity check, no strip char, no start/stop output control.
        raw.c_iflag &= ~UInt(BRKINT | ICRNL | INPCK | ISTRIP | IXON)
        // Output flags: disable post-processing of output.
        raw.c_oflag &= ~UInt(OPOST)
        // Control flags: set character size to 8 bits per byte.
        raw.c_cflag |= UInt(CS8)
        // Local flags: no echo, no canonical mode, no extended input processing, no signal chars (^C, ^Z).
        raw.c_lflag &= ~UInt(ECHO | ICANON | IEXTEN | ISIG)

        // Timeout settings for read():
        raw.c_cc.16 = 0 // VMIN: Minimum number of bytes for read() to return (0 = return immediately)
        raw.c_cc.17 = 1 // VTIME: Timeout in deciseconds (1 = 100ms timeout)

        guard tcsetattr(STDIN_FILENO, TCSAFLUSH, &raw) == 0 else {
            perror("Error setting terminal attributes (tcsetattr)")
            return nil
        }

        isRawModeSet = true
        savedTermios = originalTermios
        return originalTermios // Return original settings for restoration
    }

    // Restores terminal to its original settings
    private static func restoreRawMode(originalTermios: termios?) {
         if !isRawModeSet { return } // Only restore if raw mode was set

        if var termios = originalTermios {
            if tcsetattr(STDIN_FILENO, TCSAFLUSH, &termios) != 0 {
                perror("Error restoring terminal attributes (tcsetattr)")
            }
        }
        isRawModeSet = false
    }

    // --- Screen Manipulation ---
    static func clearScreen() {
        print("\u{001B}[2J", terminator: "") // Clear screen
        print("\u{001B}[H", terminator: "") // Move cursor to home position (top-left)
        fflush(stdout) // Ensure commands are sent immediately
    }

    static func moveCursorTo(row: Int, col: Int) {
        // ANSI escape code to move cursor to specific row/column (1-based)
        print("\u{001B}[\(row);\(col)H", terminator: "")
        fflush(stdout)
    }

    static func hideCursor() {
        print("\u{001B}[?25l", terminator: "")
        fflush(stdout)
    }

    static func showCursor() {
        print("\u{001B}[?25h", terminator: "")
        fflush(stdout)
    }
}

// MARK: - Main Installation Process
do {
    // Always ensure cursor is shown when script exits
    MenuCursor.hideCursor()
    defer { 
        MenuCursor.showCursor()
        print("") // Ensure clean exit
    }

    TerminalUI.showWelcome()

    // Create installer instance and check environment
    print("Initializing installer...")
    let installer = try Installer()

    // Verify dependencies
    print("Verifying dependencies...")
    try installer.verifyDependencies()
    TerminalUI.showSuccess("Dependencies verified.")

    // Download and extract repository
    print("\nSetting up repository...")
    try installer.downloadRepository()

    // Create/Verify config file
    print("\nChecking configuration file...")
    try installer.createConfigFileIfNeeded()

    // Start the interactive menu system
    let ui = InstallerUI(installer: installer)
    ui.mainMenu() // Loop until exit or successful install

    print(Term.colored("\nExiting installer.", Term.blue))

} catch InstallerError.missingDependencies(let deps) {
    // Detailed error message for missing dependencies
    MenuCursor.showCursor() // Ensure cursor is visible
    TerminalUI.showError("Missing dependencies: \(deps.joined(separator: ", "))")
    print("\nPlease install the missing dependencies with your package manager:")
    if let _ = try? Process.run(URL(fileURLWithPath: "/usr/bin/which"), arguments: ["brew"]) {
        print("  brew install \(deps.joined(separator: " "))")
    } else if let _ = try? Process.run(URL(fileURLWithPath: "/usr/bin/which"), arguments: ["apt-get"]) {
        print("  sudo apt-get install \(deps.joined(separator: " "))")
    }
    print("\nAfter installing dependencies, run this script again.")
    exit(1)
} catch {
    MenuCursor.showCursor() // Ensure cursor is visible
    TerminalUI.showError("Error: \(error.localizedDescription)")
    
    // Provide more context for certain error types
    if let installerError = error as? InstallerError {
        switch installerError {
        case .downloadFailed(let reason):
            print("Download failed: \(reason)")
            print("Check your internet connection and try again.")
        case .extractionFailed(let reason):
            print("Extraction failed: \(reason)")
            print("Try clearing any temporary files and run again.")
        case .hookInstallationFailed(let hook, let reason):
            print("Hook installation failed for \(hook): \(reason)")
            print("Make sure pre-commit is properly installed.")
        case .genericError(let message):
            print("Error details: \(message)")
        case .missingDependencies:
            // Already handled above
            break
        }
    }
    
    print("\nTry running this script again. If the problem persists, please report the issue.")
    exit(1)
} 