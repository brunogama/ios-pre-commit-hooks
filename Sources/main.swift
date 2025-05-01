import ArgumentParser
import Foundation
import Rainbow

struct PreCommitInstaller: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "pre-commit-installer",
        abstract: "A CLI tool to install pre-commit hooks for iOS development",
        subcommands: [],
        defaultSubcommand: nil
    )
    
    @Flag(name: .long, help: "Run in non-interactive mode with default selections")
    var nonInteractive: Bool = false
    
    @Flag(name: .shortAndLong, help: "Show verbose output")
    var verbose: Bool = false
    
    func run() throws {
        print("Pre-commit Hooks Installer".blue.bold)
        print("==========================".blue)
        
        // Initialize the terminal UI controller
        let controller = TerminalUIController(verbose: verbose)
        
        if nonInteractive {
            print("Running in non-interactive mode with default selections...".yellow)
            // Implement non-interactive mode logic here
        } else {
            // Start the interactive terminal UI
            controller.start()
        }
    }
}

// Use standard command-line execution
PreCommitInstaller.main() 