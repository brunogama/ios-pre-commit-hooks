import Foundation

/// Constants used throughout the application
public struct Config {
    static let configFile = ".pre-commit-config.yaml"
    static let managedSectionMarker = "# --- Managed by pre-commit-configs installer ---"
    
    // Constants from the original project
    static let repoURL = "https://github.com/brunogama/pre-commit-configs"
    static let branch = "main"
    static let archiveURL = "\(repoURL)/archive/refs/heads/\(branch).tar.gz"
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
} 