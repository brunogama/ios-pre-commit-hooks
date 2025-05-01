import Foundation

/// Constants used throughout the application as a Value Object
public struct ConfigConstants {
    /// Path to the pre-commit config file
    public static let configFile = ".pre-commit-config.yaml"
    
    /// Marker used to identify managed sections in the config file
    public static let managedSectionMarker = "# --- Managed by pre-commit-configs installer ---"
    
    /// Begin marker for template sections
    public static let beginTemplatesMarker = "# --- BEGIN MANAGED TEMPLATES ---"
    
    /// End marker for template sections
    public static let endTemplatesMarker = "# --- END MANAGED TEMPLATES ---"
    
    /// Repository URL for fetching templates
    public static let repoURL = "https://github.com/brunogama/pre-commit-configs"
    
    /// Branch to use for templates
    public static let branch = "main"
    
    /// Archive URL for downloading templates
    public static let archiveURL = "\(repoURL)/archive/refs/heads/\(branch).tar.gz"
    
    /// Directory for scripts
    public static let scriptsDir = "scripts"
    
    /// Standard header for config files
    public static let standardHeader = """
    # See https://pre-commit.com/ for more information
    # See https://pre-commit.com/hooks.html for more hooks
    # This file is managed by the pre-commit-configs installer.
    """

    /// Standard defaults for config files
    public static let standardDefaults = """
    # Default configurations (optional)
    default_stages: [pre-commit] # Sensible default
    default_install_hook_types: [pre-commit, pre-push, commit-msg]
    # default_language_version:
    #   python: python3.9
    """
    
    /// Default config content
    public static let defaultConfigContent = """
    \(standardHeader)
    
    \(standardDefaults)
    
    repos:
    # Add hooks here using the installer or manually
    """
} 