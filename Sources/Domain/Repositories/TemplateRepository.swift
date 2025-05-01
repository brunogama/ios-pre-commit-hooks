import Foundation

/// Repository interface for managing hook templates
public protocol TemplateRepository {
    /// Get the path for a named template
    /// - Parameter name: Name of the template
    /// - Returns: Path to the template file, or nil if not found
    func templatePath(for name: String) -> String?
    
    /// Get all available templates
    /// - Returns: Array of template names and descriptions
    func getAvailableTemplates() throws -> [(name: String, description: String)]
    
    /// Get all hook templates with their metadata
    /// - Returns: Array of HookTemplate entities
    func getHookTemplates() throws -> [Any]
} 