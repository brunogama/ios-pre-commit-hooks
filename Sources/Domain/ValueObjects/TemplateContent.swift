import Foundation

// Forward declaration of TemplateName to avoid import errors
// Since all these are in the same module, we should define them in a specific order
// or use proper module organization

/// Template content for adding to configuration
public final class TemplateContent {
    private let name: TemplateName
    private let content: String
    
    public init(name: TemplateName, content: String) {
        self.name = name
        self.content = content
    }
    
    public var header: String {
        return "\n\n# Template: \(name.name)\n"
    }
    
    public var body: String {
        return content
    }
} 