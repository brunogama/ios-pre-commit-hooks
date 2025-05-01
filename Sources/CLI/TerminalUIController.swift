import Foundation
import Rainbow

// ANSI escape codes for terminal control
enum TerminalControl {
    static let clearScreen = "\u{001B}[2J\u{001B}[H"
    static let cursorUp = "\u{001B}[1A"
    static let cursorDown = "\u{001B}[1B"
    static let eraseLine = "\u{001B}[2K"
    static let hideCursor = "\u{001B}[?25l"
    static let showCursor = "\u{001B}[?25h"
}

enum MenuState {
    case main
    case hooksSelection
    case scriptsSelection
    case templatesSelection
    case confirmation
    case installation
    case exit
}

// Terminal key codes
enum KeyCode {
    static let enter = 13
    static let escape = 27
    static let space = 32
    static let upArrow = 65 // After escape sequence
    static let downArrow = 66 // After escape sequence
    static let leftArrow = 68 // After escape sequence
    static let rightArrow = 67 // After escape sequence
    static let tab = 9
    static let q = 113
    static let Q = 81
    static let b = 98
    static let B = 66
}

class TerminalUIController {
    // State
    private var currentState: MenuState = .main
    private var selectedHooks: Set<String> = []
    private var selectedScripts: Set<String> = []
    private var selectedTemplates: Set<String> = [] // Store selected template directories
    private var currentSelectionIndex = 0
    
    // Available items
    private var availableHooks: [HookGroup] = []
    private var availableScripts: [(String, String)] = [] // (filename, description)
    private var availableTemplates: [HookTemplate] = [] // Hook templates from hooks-templates directory
    
    // Flags
    private var verbose: Bool
    private var exitRequested = false
    
    // Services
    private let terminalHandler = TerminalHandler()
    private var installerService: InstallerService?
    
    init(verbose: Bool = false) {
        self.verbose = verbose
        setupTerminal()
        loadAvailableHooks()
        loadAvailableTemplates()
        initializeInstallerService()
    }
    
    deinit {
        resetTerminal()
    }
    
    // Configure terminal for raw input mode
    private func setupTerminal() {
        print(TerminalControl.hideCursor, terminator: "")
    }
    
    // Reset terminal to normal state
    private func resetTerminal() {
        print(TerminalControl.showCursor, terminator: "")
    }
    
    // Initialize the installer service
    private func initializeInstallerService() {
        do {
            installerService = try InstallerService(verbose: verbose)
            try installerService?.verifyDependencies()
            try installerService?.downloadRepository { progress, message in
                if self.verbose {
                    print("\r\(message) [\(Int(progress * 100))%]", terminator: "")
                    fflush(stdout)
                    
                    if progress >= 1.0 {
                        print("") // Line break after completion
                    }
                }
            }
            
            if let templates = try installerService?.getAvailableTemplates() {
                availableScripts = templates
            }
        } catch {
            print("Error initializing: \(error.localizedDescription)".red)
            // Continue without repository data, we'll show built-in data
        }
    }
    
    // Load available hooks from predefined list
    private func loadAvailableHooks() {
        // For now, use a simplified list - we'll expand this later
        availableHooks = [
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
                    )
                ]
            )
        ]
    }
    
    // Load available hook templates
    private func loadAvailableTemplates() {
        do {
            // Create a temporary installer service to read templates
            let tempService = try InstallerService(verbose: verbose)
            availableTemplates = try tempService.getHookTemplates()
            
            if verbose {
                print("Loaded \(availableTemplates.count) hook templates".green)
            }
        } catch {
            print("Error loading hook templates: \(error.localizedDescription)".red)
        }
    }
    
    // Main entry point for the UI controller
    func start() {
        clearScreen()
        
        while !exitRequested {
            switch currentState {
            case .main:
                renderMainMenu()
            case .templatesSelection:
                renderHooksSelectionMenu()
            case .hooksSelection:
                renderHooksMenu()
            case .scriptsSelection:
                renderScriptsSelectionMenu()
            case .confirmation:
                renderConfirmationScreen()
            case .installation:
                performInstallation()
            case .exit:
                exitRequested = true
            }
        }
    }
    
    // Clear the terminal screen
    private func clearScreen() {
        print(TerminalControl.clearScreen, terminator: "")
        fflush(stdout)
    }
    
    // MARK: - Menu Rendering
    
    private func renderMainMenu() {
        clearScreen()
        print("Pre-commit Hooks Installer".blue.bold)
        print("==========================".blue)
        print("")
        
        let menuItems = [
            "Configure Templates (selected: \(selectedTemplates.count))",
            "Configure Hooks (selected: \(selectedHooks.count))",
            "Configure Scripts (selected: \(selectedScripts.count))",
            "Install Selected Items",
            "Exit"
        ]
        
        for (index, item) in menuItems.enumerated() {
            let marker = index == currentSelectionIndex ? ">" : " "
            print("\(marker) \(item)")
        }
        
        print("\nUse up/down arrows to navigate, Enter to select")
        
        // Handle input
        handleMainMenuInput()
    }
    
    private func renderHooksSelectionMenu() {
        clearScreen()
        print("Hook Template Selection".blue.bold)
        print("======================".blue)
        print("")
        
        if availableTemplates.isEmpty {
            print("No hook templates found.".yellow)
            print("\nPress Enter to return to main menu...")
            
            // Wait for Enter key
            while true {
                if let key = terminalHandler.readKeystroke(), case .enter = key {
                    currentState = .main
                    currentSelectionIndex = 0
                    return
                }
            }
        }
        
        // Display templates
        for (index, template) in availableTemplates.enumerated() {
            let isSelected = selectedTemplates.contains(template.directory)
            let marker = index == currentSelectionIndex ? ">" : " "
            let checkBox = isSelected ? "[✓]" : "[ ]"
            
            print("\(marker) \(checkBox) \(template.name)")
            print("     \(template.description)")
            print("")
        }
        
        print("Use up/down arrows to navigate, Space to toggle, Enter to confirm, b to go back".blue)
        
        // Handle input
        handleHookTemplatesMenuInput()
    }
    
    private func renderScriptsSelectionMenu() {
        clearScreen()
        print("Script Selection".blue.bold)
        print("===============".blue)
        print("")
        
        // If we have script templates from the repository, use those
        var menuItems: [(String, String)] = []
        
        if availableScripts.isEmpty {
            menuItems = [
                ("accessibility-check.sh", "Checks for accessibility implementation"),
                ("check-xcode-dangling-refs.sh", "Validates Xcode project settings")
            ]
        } else {
            // Create menu items from available scripts
            menuItems = availableScripts.map { filename, description in
                let isSelected = selectedScripts.contains(filename)
                let checkBox = isSelected ? "[✓]" : "[ ]"
                return ("\(checkBox) \(filename)", description)
            }
        }
        
        // Ensure valid selection
        if currentSelectionIndex >= menuItems.count {
            currentSelectionIndex = 0
        }
        
        for (index, item) in menuItems.enumerated() {
            let marker = index == currentSelectionIndex ? ">" : " "
            print("\(marker) \(item.0)")
            print("     \(item.1)")
        }
        
        print("\nUse up/down arrows to navigate, Space to toggle, Enter to confirm, b to go back")
        
        // Handle key input
        handleScriptsMenuInput(menuItems)
    }
    
    private func renderConfirmationScreen() {
        clearScreen()
        print("Installation Confirmation".blue.bold)
        print("========================".blue)
        print("")
        
        // Show selected hook templates
        print("Selected hook templates:".yellow)
        if selectedTemplates.isEmpty {
            print("  None")
        } else {
            for templateDir in selectedTemplates {
                if let template = availableTemplates.first(where: { $0.directory == templateDir }) {
                    print("  • \(template.name)")
                } else {
                    print("  • \(templateDir)")
                }
            }
        }
        
        // Show selected hooks
        print("\nSelected hooks:".yellow)
        if selectedHooks.isEmpty {
            print("  None")
        } else {
            for hookId in selectedHooks {
                print("  • \(hookId)")
            }
        }
        
        // Show selected scripts
        print("\nSelected scripts:".yellow)
        if selectedScripts.isEmpty {
            print("  None")
        } else {
            for scriptId in selectedScripts {
                print("  • \(scriptId)")
            }
        }
        
        print("\nReady to install \(selectedTemplates.count) templates, \(selectedHooks.count) hooks, and \(selectedScripts.count) scripts.")
        print("\nOptions:".yellow)
        print("  1. Proceed with installation")
        print("  2. Return to main menu")
        print("  3. Cancel and exit")
        
        print("\nEnter your choice (1-3): ", terminator: "")
        fflush(stdout)
        
        // Wait for keystroke
        while true {
            if let key = terminalHandler.readKeystroke() {
                switch key {
                case .character("1"):
                    print("1")
                    currentState = .installation
                    return
                case .character("2"):
                    print("2")
                    currentState = .main
                    currentSelectionIndex = 0
                    return
                case .character("3"):
                    print("3")
                    currentState = .exit
                    return
                default:
                    break
                }
            }
        }
    }
    
    private func performInstallation() {
        clearScreen()
        print("Installation in Progress".blue.bold)
        print("=======================".blue)
        print("")
        
        do {
            // 1. Verify dependencies again
            print("Verifying dependencies...".yellow)
            try installerService?.verifyDependencies()
            print("✓ Dependencies verified".green)
            
            // 2. Setup scripts if any selected
            if !selectedScripts.isEmpty {
                print("\nSetting up scripts...".yellow)
                try installerService?.setupScripts(Array(selectedScripts))
                print("✓ Scripts installed".green)
            }
            
            // 3. Update config file with selected hooks
            if !selectedHooks.isEmpty {
                print("\nUpdating configuration file with selected hooks...".yellow)
                try installerService?.updateConfigFile(hookIds: selectedHooks, availableHooks: availableHooks)
                print("✓ Configuration file updated with hooks".green)
            }
            
            // 4. Update config file with selected templates
            if !selectedTemplates.isEmpty {
                print("\nUpdating configuration file with selected templates...".yellow)
                try installerService?.updateConfigFileWithTemplates(selectedTemplates: Array(selectedTemplates))
                print("✓ Configuration file updated with templates".green)
            }
            
            // 5. Install hook types
            let hookTypes = ["pre-commit", "pre-push"]
            print("\nInstalling hooks...".yellow)
            try installerService?.installHooks(types: hookTypes)
            print("✓ Hooks installed".green)
            
            print("\n✅ Installation completed successfully!".green.bold)
        } catch {
            print("\n❌ Installation failed: \(error.localizedDescription)".red.bold)
        }
        
        print("\nPress Enter to exit...")
        
        // Wait for Enter
        while true {
            if let key = terminalHandler.readKeystroke(), case .enter = key {
                break
            }
        }
        
        currentState = .exit
    }
    
    // MARK: - Input Handling
    
    private func handleMainMenuInput() {
        if let key = terminalHandler.readKeystroke() {
            switch key {
            case .arrowUp:
                currentSelectionIndex = max(0, currentSelectionIndex - 1)
                renderMainMenu()
            case .arrowDown:
                currentSelectionIndex = min(4, currentSelectionIndex + 1) // 5 menu items
                renderMainMenu()
            case .enter:
                switch currentSelectionIndex {
                case 0:
                    currentState = .templatesSelection
                    currentSelectionIndex = 0
                case 1:
                    currentState = .hooksSelection
                    currentSelectionIndex = 0
                case 2:
                    currentState = .scriptsSelection
                    currentSelectionIndex = 0
                case 3:
                    if selectedTemplates.isEmpty && selectedHooks.isEmpty && selectedScripts.isEmpty {
                        // Show warning if nothing selected
                        clearScreen()
                        print("Warning: Nothing Selected".yellow.bold)
                        print("Please select at least one template, hook, or script before installation.".yellow)
                        print("\nPress Enter to continue...")
                        
                        // Wait for Enter
                        while true {
                            if let key = terminalHandler.readKeystroke(), case .enter = key {
                                break
                            }
                        }
                        renderMainMenu() // Rerender main menu after warning
                    } else {
                        currentState = .confirmation
                    }
                case 4:
                    currentState = .exit
                default:
                    break
                }
            case .character("q"), .character("Q"):
                currentState = .exit
            default:
                // Ignore other keys, main loop will call again
                break
            }
        }
    }
    
    private func handleHookTemplatesMenuInput() {
        if let key = terminalHandler.readKeystroke() {
            switch key {
            case .arrowUp:
                currentSelectionIndex = max(0, currentSelectionIndex - 1)
                renderHooksSelectionMenu() // Re-render the same menu
            case .arrowDown:
                currentSelectionIndex = min(availableTemplates.count - 1, currentSelectionIndex + 1)
                renderHooksSelectionMenu() // Re-render the same menu
            case .space:
                // Toggle selection for current template
                if currentSelectionIndex < availableTemplates.count {
                    let template = availableTemplates[currentSelectionIndex]
                    if selectedTemplates.contains(template.directory) {
                        selectedTemplates.remove(template.directory)
                    } else {
                        selectedTemplates.insert(template.directory)
                    }
                    print("DEBUG: Toggled template \(template.directory). Selected: \(selectedTemplates)") // DEBUG
                    renderHooksSelectionMenu() // Re-render the same menu
                }
            case .enter:
                currentState = .main
                currentSelectionIndex = 0
            case .character("b"), .character("B"), .escape:
                currentState = .main
                currentSelectionIndex = 0
            default:
                // Ignore other keys
                break
            }
        }
    }
    
    private func handleScriptsMenuInput(_ items: [(String, String)]) {
        if let key = terminalHandler.readKeystroke() {
            switch key {
            case .arrowUp:
                currentSelectionIndex = max(0, currentSelectionIndex - 1)
                renderScriptsSelectionMenu() // Re-render the same menu
            case .arrowDown:
                currentSelectionIndex = min(items.count - 1, currentSelectionIndex + 1)
                renderScriptsSelectionMenu() // Re-render the same menu
            case .space:
                // Extract filename from the menu item (remove checkbox)
                let item = items[currentSelectionIndex]
                let parts = item.0.components(separatedBy: "] ")
                if parts.count > 1 {
                    let filename = parts[1].trimmingCharacters(in: .whitespaces)
                    
                    if selectedScripts.contains(filename) {
                        selectedScripts.remove(filename)
                    } else {
                        selectedScripts.insert(filename)
                    }
                    print("DEBUG: Toggled script \(filename). Selected: \(selectedScripts)") // DEBUG
                    renderScriptsSelectionMenu() // Re-render the same menu
                }
            case .enter:
                currentState = .main
                currentSelectionIndex = 0
            case .character("b"), .character("B"), .escape:
                currentState = .main
                currentSelectionIndex = 0
            default:
                // Ignore other keys
                break
            }
        }
    }
    
    // Add the renderHooksMenu method to display original hooks
    private func renderHooksMenu() {
        clearScreen()
        print("Hook Selection".blue.bold)
        print("=============".blue)
        print("")
        
        var flattenedMenuItems: [(String, String, HookGroup, Hook?)] = []
        
        // Add each group and its hooks to the flattened list
        for group in availableHooks {
            // Add group header
            flattenedMenuItems.append((group.name, group.description, group, nil))
            
            // Add each hook
            for hook in group.hooks {
                let isSelected = selectedHooks.contains(hook.id)
                let checkBox = isSelected ? "[✓]" : "[ ]"
                flattenedMenuItems.append(("\(checkBox) \(hook.id)", hook.description, group, hook))
            }
        }
        
        // Ensure current selection is valid
        if currentSelectionIndex >= flattenedMenuItems.count {
            currentSelectionIndex = 0
        }
        
        for (index, item) in flattenedMenuItems.enumerated() {
            let isHeader = item.3 == nil
            let marker = index == currentSelectionIndex ? ">" : " "
            
            if isHeader {
                print("\(marker) \(item.0.yellow)")
                print("   \(item.1.dim)")
            } else {
                print("\(marker) \(item.0)")
                print("     \(item.1)")
            }
        }
        
        print("\nUse up/down arrows to navigate, Space to toggle, Enter to confirm, b to go back".blue)
        
        // Handle input
        handleHooksMenuInput(flattenedMenuItems)
    }
    
    // Original hooks menu input handler
    private func handleHooksMenuInput(_ items: [(String, String, HookGroup, Hook?)]) {
        if let key = terminalHandler.readKeystroke() {
            switch key {
            case .arrowUp:
                currentSelectionIndex = max(0, currentSelectionIndex - 1)
                renderHooksMenu() // Re-render the same menu
            case .arrowDown:
                currentSelectionIndex = min(items.count - 1, currentSelectionIndex + 1)
                renderHooksMenu() // Re-render the same menu
            case .space:
                // Toggle selection if it's a hook (not a header)
                if let hook = items[currentSelectionIndex].3 {
                    if selectedHooks.contains(hook.id) {
                        selectedHooks.remove(hook.id)
                    } else {
                        selectedHooks.insert(hook.id)
                    }
                    print("DEBUG: Toggled hook \(hook.id). Selected: \(selectedHooks)") // DEBUG
                    renderHooksMenu() // Re-render the same menu
                }
            case .enter:
                currentState = .main
                currentSelectionIndex = 0
            case .character("b"), .character("B"), .escape:
                currentState = .main
                currentSelectionIndex = 0
            default:
                // Ignore other keys
                break
            }
        }
    }
} 