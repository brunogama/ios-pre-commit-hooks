import Foundation

/// Hook template entity representing a pre-commit hook template
public struct HookTemplate {
    /// The display name of the template
    public let name: String
    
    /// The directory name where the template is stored
    public let directory: String
    
    /// Description of what the template does
    public let description: String
    
    /// The actual YAML configuration content
    public let configuration: String
    
    /// Whether this template is currently selected
    public let isSelected: Bool
    
    public init(name: String, directory: String, description: String, configuration: String, isSelected: Bool) {
        self.name = name
        self.directory = directory
        self.description = description
        self.configuration = configuration
        self.isSelected = isSelected
    }
} 