import Foundation

/// Domain service interface for configuration management
public protocol ConfigurationService {
    /// Create the default configuration file if it doesn't exist
    /// - Parameter path: Path where the file should be created
    /// - Throws: Error if the file cannot be created
    func createDefaultConfigIfNeeded(atPath path: String) throws
    
    /// Update the config file with selected templates
    /// - Parameters:
    ///   - selectedTemplates: List of template names to include
    ///   - configPath: Path to the config file
    /// - Returns: Dictionary containing the updated config and included templates
    /// - Throws: Error if updating the config fails
    func updateConfigFile(withTemplates selectedTemplates: [String], atPath configPath: String) throws -> [String: Any]
    
    /// Add a template to the configuration
    /// - Parameters:
    ///   - template: Template name
    ///   - templatePath: Path to the template file
    ///   - configPath: Path to the config file
    /// - Throws: Error if adding the template fails
    func addTemplate(name template: String, fromPath templatePath: String, toConfigAt configPath: String) throws
    
    /// Ensure the managed section marker exists in the config
    /// - Parameter configPath: Path to the config file
    /// - Throws: Error if adding the marker fails
    func ensureManagedSectionMarker(inConfigAt configPath: String) throws
} 