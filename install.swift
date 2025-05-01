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
    case configureScripts
    case installSelected
    case exit
    
    static var all: [(MenuOption, String, String)] {
        [
            (.configureHooks, "Configure Hooks", "Select and configure pre-commit hooks"),
            (.configureScripts, "Configure Scripts", "Select and configure local script templates"),
            (.installSelected, "Install Selected Items", "Install all selected hooks and scripts"),
            (.exit, "Exit", "Exit the installer")
        ]
    }
}

// MARK: - Installer UI
class InstallerUI {
    private var selectedHooks: Set<String> = []
    private var selectedScripts: Set<String> = []
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
            print("Selected: \(selectedHooks.count) hooks, \(selectedScripts.count) scripts\n")
            
            // Display menu items
            for (index, option) in options.enumerated() {
                let cursor = index == currentSelection ? Term.colored(">", Term.green) : " "
                print("\(cursor) \(option.1) (selected: \(getSelectionCountForOption(option.0)))")
            }
            
            // Instructions
            print("\nUse up/down arrows to navigate, Enter to select")
            fflush(stdout)
            
            // Process key input
            if let key = MenuCursor.readKey() {
                print("DEBUG: Key pressed: \(key)") // Debug key detection
                
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
                    case .configureScripts:
                        configureScripts()
                    case .installSelected:
                        if installSelected() { return } // Exit if installation successful
                    case .exit:
                        if confirmExit() { return } // Exit if confirmed
                    }
                    
                // Simple numeric selection
                case "1", "2", "3", "4", "5":
                    if let selectedIndex = Int(key), selectedIndex > 0, selectedIndex <= options.count {
                        currentSelection = selectedIndex - 1
                    }
                default:
                    // Ignore other keys
                    break
                }
            }
            
            // Short sleep to prevent CPU hogging
            usleep(10000)
        }
    }
    
    // Helper to get selection count for menu display
    private func getSelectionCountForOption(_ option: MenuOption) -> Int {
        switch option {
        case .configureHooks:
            return selectedHooks.count
        case .configureScripts:
            return selectedScripts.count
        case .installSelected, .exit:
            return 0
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

    // MARK: - Script Configuration Logic
    private func configureScripts() {
        guard let templates = try? installer.getAvailableTemplates() else {
            TerminalUI.showError("Could not load script templates")
            sleep(2)
            return
        }

        if templates.isEmpty {
            TerminalUI.showWarning("No script templates available.")
            print("Press Enter to continue...")
            _ = MenuCursor.waitForEnter() // Wait for Enter
            return
        }

        var currentSelection = 0
        var currentSelections = selectedScripts
        
        while true {
            MenuCursor.clearScreen()
            
            print(Term.colored("Script Template Configuration", Term.blue))
            print("Selected: \(currentSelections.count) scripts\n")
            
            // Display menu items
            for (index, template) in templates.enumerated() {
                let isSelected = currentSelections.contains(template.0)
                let cursor = index == currentSelection ? Term.colored(">", Term.green) : " "
                let checkbox = isSelected ? "[✓]" : "[ ]"
                
                print("\(cursor) \(checkbox) \(template.0)")
                // If this is the current selection, show the description
                if index == currentSelection {
                    print("       \(template.1)")
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
                    if currentSelection < templates.count - 1 {
                        currentSelection += 1
                    }
                case MenuCursor.space:
                    // Toggle selection for current item
                    let scriptId = templates[currentSelection].0
                    if currentSelections.contains(scriptId) {
                        currentSelections.remove(scriptId)
                    } else {
                        currentSelections.insert(scriptId)
                    }
                case MenuCursor.enter:
                    // Save selections and return
                    selectedScripts = currentSelections
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

    // MARK: - Generic Menu Presentation Logic
    enum MenuSelectionMode {
        case single // Returns .selected(index) or .aborted
        case multiple // Returns .selectedMultiple(indices) or .aborted
    }

    enum MenuResult {
        case selected(Int)
        case selectedMultiple(Set<Int>)
        case aborted // User pressed Esc or 'b'
        case noSelection // Should not happen if properly handled
    }

    private func presentMenu(
        title: String,
        subtitle: String? = nil,
        items: [(String, String)], // (Display Name, Description)
        initialSelections: Set<Int> = [],
        selectedIndex: Int = 0,
        footer: String,
        allowNumericSelection: Bool,
        selectionMode: MenuSelectionMode
    ) -> MenuResult {
        var currentSelection = selectedIndex
        var currentSelections = initialSelections
        let maxSelection = items.count - 1

        // Ensure initial selection is valid and selectable
        if !isItemSelectable(items[currentSelection].0) {
            // Find the first selectable item
            for (index, item) in items.enumerated() {
                if isItemSelectable(item.0) {
                    currentSelection = index
                    break
                }
            }
        }

        while true {
            MenuCursor.clearScreen()
            print(Term.colored(title, Term.blue))
            if let subtitle = subtitle {
                print(Term.colored(subtitle, Term.yellow))
            }
            print("")

            for (index, item) in items.enumerated() {
                let isSelected = currentSelections.contains(index)
                let isCurrent = index == currentSelection
                
                // Determine if item is selectable (non-header)
                let isSelectable = isItemSelectable(item.0)

                // Display cursor only for current selectable item
                let cursor = isCurrent && isSelectable ? Term.colored(">", Term.green) : " "
                
                // Display marker
                let marker: String
                if isSelectable {
                    switch selectionMode {
                    case .single: 
                        marker = isCurrent ? "●" : "○" // Radio button style
                    case .multiple: 
                        marker = isSelected ? "✓" : " " // Checkbox style
                    }
                    print("\(cursor) [\(marker)] \(item.0)")
                } else {
                    // This is a header item (item.1 contains the formatted header)
                    print("\(cursor) \(item.1)") 
                }

                // Print description if available and not a header
                if isSelectable && !item.1.isEmpty {
                    // Indent description lines
                    item.1.split(separator: "\n").forEach { line in
                        print("    \(line)")
                    }
                }
                
                // Add spacing after each item
                print("")
            }

            print(Term.colored(footer, Term.blue))
            fflush(stdout)

            // Read key input
            guard let key = MenuCursor.readKey() else { continue }

            switch key {
            case MenuCursor.up:
                // Find the previous selectable index
                var prevIndex = currentSelection - 1
                while prevIndex >= 0 {
                    if isItemSelectable(items[prevIndex].0) {
                        currentSelection = prevIndex
                        break // Found the previous selectable item
                    }
                    prevIndex -= 1 // Continue searching upwards
                }

            case MenuCursor.down:
                // Find the next selectable index
                var nextIndex = currentSelection + 1
                while nextIndex <= maxSelection {
                    if isItemSelectable(items[nextIndex].0) {
                        currentSelection = nextIndex
                        break // Found the next selectable item
                    }
                    nextIndex += 1 // Continue searching downwards
                }

            case MenuCursor.space:
                // Toggle selection for current item if in multiple selection mode and selectable
                if selectionMode == .multiple && isItemSelectable(items[currentSelection].0) {
                    if currentSelections.contains(currentSelection) {
                        currentSelections.remove(currentSelection)
                    } else {
                        currentSelections.insert(currentSelection)
                    }
                }

            case MenuCursor.enter:
                // Handle Enter key based on selection mode
                switch selectionMode {
                case .single:
                    // Only return if the current selection is actually selectable
                    if isItemSelectable(items[currentSelection].0) {
                        return .selected(currentSelection)
                    }
                case .multiple:
                    // Return all selected indices (which should only contain selectable items)
                    return .selectedMultiple(currentSelections)
                }

            case MenuCursor.escape, "b", "B":
                return .aborted

            default:
                // Handle numeric selection if allowed
                if allowNumericSelection, let num = Int(key), num > 0 {
                     // Map number input to the Nth *selectable* item if possible
                     // Or handle direct index mapping if that's the intended behavior
                     let targetIndex = num - 1 // Assuming direct index mapping for now
                    if targetIndex <= maxSelection && isItemSelectable(items[targetIndex].0) {
                        currentSelection = targetIndex
                        
                        // For multiple selection mode, numeric input toggles selection
                        if selectionMode == .multiple {
                            if currentSelections.contains(targetIndex) {
                                currentSelections.remove(targetIndex)
                            } else {
                                currentSelections.insert(targetIndex)
                            }
                        } 
                        // In single selection, just move the cursor, Enter confirms.
                    }
                }
            }
        }
    }
    
    // Helper to check if an item is selectable
    private func isItemSelectable(_ identifier: String) -> Bool {
        // Only treat exact matches for header markers as non-selectable
        return identifier != "[Group]" && identifier != "[Desc]"
    }
    
    private func showSelectedForConfirmation() {
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

        if selectedScripts.isEmpty {
            print("\nNo scripts selected")
        } else {
            print(Term.colored("\nSelected Scripts:", Term.yellow))
            if let templates = try? installer.getAvailableTemplates() {
                 let sortedSelectedScripts = selectedScripts.sorted()
                for templateName in sortedSelectedScripts {
                     if let template = templates.first(where: { $0.0 == templateName }) {
                         print("    • \(template.0) (\(Term.colored(template.1, Term.yellow)))")
                     } else {
                         print("    • \(templateName)") // Fallback if description not found
                     }
                }
            } else {
                 // Print sorted names if templates couldn't be re-fetched
                 selectedScripts.sorted().forEach { print("    • \($0)") }
            }
        }

        // print("\nPress Enter to continue...") // Remove wait
        // fflush(stdout)
        // _ = MenuCursor.waitForEnter() // Remove wait
        print("\n" + String(repeating: "-", count: 25)) // Add separator
    }
    
    private func installSelected() -> Bool {
        MenuCursor.clearScreen()

        if selectedHooks.isEmpty && selectedScripts.isEmpty {
            TerminalUI.showWarning("Nothing selected to install!")
            print("\nPress Enter to continue...")
            _ = MenuCursor.waitForEnter()
            return false
        }

        // Show what will be installed before confirming
        showSelectedForConfirmation()

        print(Term.colored("\nReady to install:", Term.blue)) // Add newline for spacing
        print("  • \(selectedHooks.count) hooks")
        print("  • \(selectedScripts.count) scripts")

        if !TerminalUI.confirm("Proceed with installation?") {
            return false // User cancelled
        }

        // --- Installation Process ---
        MenuCursor.clearScreen()
        print(Term.colored("Installing...", Term.blue))
        var success = true
        var errorMessage = ""

        do {
            // 1. Create Config File (if needed, though logic might be better placed earlier)
             if !FileManager.default.fileExists(atPath: Config.configFile) {
                 print(Term.colored("Creating configuration file...", Term.yellow))
                 // Consider confirming this again or ensuring it's done before selection
                 try installer.createConfigFileIfNeeded() // Assume Installer handles check + creation
                 TerminalUI.showSuccess("Configuration file created/verified.")
             }

            // 2. Setup Scripts
            if !selectedScripts.isEmpty {
                print(Term.colored("Setting up scripts...", Term.yellow))
                try installer.setupScripts(Array(selectedScripts))
                TerminalUI.showSuccess("Scripts installed.")
            } else {
                 print("Skipping script setup (none selected).")
            }

            // 3. Update Config File with Selected Hooks
            if !selectedHooks.isEmpty {
                 print(Term.colored("Updating configuration file with selected hooks...", Term.yellow))
                 try installer.updateConfigFile(selectedHookIds: selectedHooks)
                 TerminalUI.showSuccess("Configuration file updated.")
            } else {
                 print("Skipping config file update (no hooks selected).")
            }


            // 4. Install Hooks via pre-commit command
            // Determine hook types to install (e.g., from config or default)
            let hookTypesToInstall = ["pre-commit", "pre-push", "commit-msg"] // Example, could be configurable
            if !hookTypesToInstall.isEmpty {
                 print(Term.colored("Running 'pre-commit install' for \(hookTypesToInstall.joined(separator: ", "))...", Term.yellow))
                 try installer.installHooks(types: hookTypesToInstall) // Pass specific types
                 TerminalUI.showSuccess("Pre-commit hooks installed.")
            }


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
        return success // Return true if installation was successful and we should exit the main loop
    }
    
    private func confirmExit() -> Bool {
        if selectedHooks.isEmpty && selectedScripts.isEmpty {
            return true // Nothing selected, safe to exit
        }

        MenuCursor.clearScreen()
        print(Term.colored("You have uninstalled selections:", Term.yellow))
        print("  • \(selectedHooks.count) hooks")
        print("  • \(selectedScripts.count) scripts")

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
        guard fileManager.fileExists(atPath: configPath) else {
            throw InstallerError.genericError("Configuration file not found at \(configPath)")
        }

        // --- Basic YAML Generation (Not Robust Parsing/Editing) ---
        // This assumes a simple structure and appends. A proper YAML parser would be better.
        var configContent = try String(contentsOfFile: configPath, encoding: .utf8)

        // Remove existing hooks managed by this installer to avoid duplicates (simple approach)
        let lines = configContent.components(separatedBy: .newlines)
        var newLines: [String] = []
        var inManagedRepo = false
        let repoMarker = "# Managed by pre-commit-configs installer" // Marker comment
        for line in lines {
             // Detect start of potentially managed repo sections based on known repos or a marker
             if line.contains("repo: https://github.com/pre-commit/pre-commit-hooks") ||
                line.contains("repo: https://github.com/realm/SwiftLint") ||
                line.contains("repo: https://github.com/nicklockwood/SwiftFormat") ||
                line.contains("repo: local") || // Include local hooks
                line.contains(repoMarker) { // Or detect our marker
                 inManagedRepo = true
                 // Keep the repo line itself unless it's just the marker
                 if !line.contains(repoMarker) {
                     newLines.append(line)
                 }
             } else if inManagedRepo && !line.trimmingCharacters(in: .whitespaces).starts(with: "-") && !line.trimmingCharacters(in: .whitespaces).isEmpty {
                 // If we were in a managed repo and hit a line that's not indented (likely a new repo or end of file)
                 inManagedRepo = false
                 newLines.append(line) // Keep this line
             } else if !inManagedRepo {
                 // Keep lines that are not part of a managed repo section
                 newLines.append(line)
             }
             // Discard lines within a managed repo section (they will be regenerated)
         }
         configContent = newLines.joined(separator: "\n")

        // Ensure 'repos:' key exists
        if !configContent.contains("\nrepos:") {
             configContent += "\nrepos:\n"
        }

        // Group selected hooks by repo
        var hooksByRepo: [String: [(id: String, rev: String)]] = [:]
        var localHooks: [(id: String, name: String, entry: String, language: String, files: String)] = []

        for hookId in selectedHookIds {
            if let hook = availableHooks.flatMap({ $0.hooks }).first(where: { $0.id == hookId }) {
                if hook.repo == "local" {
                    // Define local hook entries (example structure)
                     // These need to be defined based on the actual script names and functionality
                     var entry = ""
                     var files = ""
                     let name = hook.description // Use description as name for local hook
                     let language = "script"

                     switch hook.id {
                     case "accessibility-check":
                         entry = "\(Config.scriptsDir)/accessibility-check.sh"
                         files = "\\.swift$" // Example: Run on Swift files
                     case "xcode-project-check":
                         entry = "\(Config.scriptsDir)/check-xcode-dangling-refs.sh" // Assuming script name
                         files = "\\.pbxproj$" // Example: Run on project files
                     case "unused-assets-check":
                          entry = "\(Config.scriptsDir)/check-unused-assets.sh" // Assuming script name
                          files = "\\.(swift|storyboard|xib)$" // Example: Files where assets might be referenced
                     default:
                         entry = "\(Config.scriptsDir)/\(hookId).sh" // Default assumption
                         files = "" // Run on all files by default if not specified
                     }
                     localHooks.append((id: hook.id, name: name, entry: entry, language: language, files: files))

                } else {
                    if hooksByRepo[hook.repo] == nil {
                        hooksByRepo[hook.repo] = []
                    }
                    // Avoid duplicates within the same repo/rev group
                    if !hooksByRepo[hook.repo]!.contains(where: { $0.id == hook.id && $0.rev == hook.rev }) {
                        hooksByRepo[hook.repo]!.append((id: hook.id, rev: hook.rev))
                    }
                }
            }
        }

        // Append hooks to config content
        var additions = "\n" + repoMarker + "\n" // Add marker to identify managed section

        for (repo, hooks) in hooksByRepo.sorted(by: { $0.key < $1.key }) {
            // Assuming all hooks from the same repo in our list use the same rev for simplicity
            if let rev = hooks.first?.rev {
                additions += "-   repo: \(repo)\n"
                additions += "    rev: \(rev)\n"
                additions += "    hooks:\n"
                for hook in hooks.sorted(by: { $0.id < $1.id }) {
                    additions += "      - id: \(hook.id)\n"
                 }
             }
        }

        // Append local hooks
         if !localHooks.isEmpty {
             additions += "-   repo: local\n"
             additions += "    hooks:\n"
             for hook in localHooks.sorted(by: { $0.id < $1.id }) {
                 additions += "      - id: \(hook.id)\n"
                 additions += "        name: \"\(hook.name)\"\n" // Quoted name
                 additions += "        entry: \(hook.entry)\n"
                 additions += "        language: \(hook.language)\n"
                 if !hook.files.isEmpty {
                     additions += "        files: \(hook.files)\n"
                 }
                 additions += "        stages: [pre-commit]\n" // Sensible default stage
             }
         }

        // Write the modified content back
        try (configContent + additions).write(toFile: configPath, atomically: true, encoding: .utf8)
    }
    
    func installHooks(types: [String]) throws {
        guard !types.isEmpty else {
            TerminalUI.showWarning("No hook types specified for installation.")
            return
        }

        for hookType in types {
            TerminalUI.showProgress(title: "Installing Hooks", progress: 0.0, message: "Running pre-commit install -t \(hookType)...")
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/usr/bin/env") // Use env to find pre-commit in PATH
            process.arguments = ["pre-commit", "install", "-t", hookType, "--install-hooks"] // Ensure hooks are installed

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe

            do {
                try process.run()
                process.waitUntilExit()

                if process.terminationStatus != 0 {
                    let errorData = pipe.fileHandleForReading.readDataToEndOfFile()
                    let errorString = String(data: errorData, encoding: .utf8) ?? "Unknown pre-commit error"
                    throw InstallerError.hookInstallationFailed(hookType, errorString)
                }
                TerminalUI.showProgress(title: "Installing Hooks", progress: 1.0, message: "Hook type '\(hookType)' installed.")
            } catch {
                 // Catch errors from process.run() itself
                 throw InstallerError.hookInstallationFailed(hookType, "Failed to execute pre-commit command: \(error.localizedDescription)")
            }
        }
    }
    
    func createConfigFileIfNeeded() throws {
        if !fileManager.fileExists(atPath: Config.configFile) {
            TerminalUI.showWarning("Configuration file \(Config.configFile) not found.")
            if TerminalUI.confirm("Create a new default .pre-commit-config.yaml file?") {
                 let configContent = """
                 # Default configurations generated by pre-commit-configs installer
                 # See https://pre-commit.com/ for more information
                 # See https://pre-commit.com/hooks.html for more hooks

                 # Define default stages if needed, otherwise hooks define their own
                 # default_stages: [commit]

                 # Default install types for `pre-commit install`
                 default_install_hook_types: [pre-commit, pre-push, commit-msg]

                 # Specify language versions if needed
                 # default_language_version:
                 #   python: python3.9

                 repos:
                 # Add repositories and hooks below, or use the installer menu
                 """
                 do {
                    try configContent.write(toFile: Config.configFile, atomically: true, encoding: .utf8)
                    TerminalUI.showSuccess("Created \(Config.configFile)")
                 } catch {
                      throw InstallerError.genericError("Failed to create \(Config.configFile): \(error.localizedDescription)")
                 }
            } else {
                 TerminalUI.showWarning("Skipping config file creation. Installation might fail if the file is required.")
            }
        } else {
             TerminalUI.showSuccess("Configuration file \(Config.configFile) found.")
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