import Foundation

/// Template registry for managing hook templates
public protocol TemplateRegistryProtocol {
    func templatePath(for name: TemplateName) -> FilePath?
} 