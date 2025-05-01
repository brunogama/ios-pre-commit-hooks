import Foundation
import Domain.Protocols
import Domain.ValueObjects

/// Default implementation of template registry using Bundle resources
public final class TemplateRegistry: TemplateRegistryProtocol {
    private let bundle: Bundle
    
    public init(bundle: Bundle = .main) {
        self.bundle = bundle
    }
    
    public func templatePath(for name: TemplateName) -> FilePath? {
        guard let path = bundle.path(forResource: name.name, ofType: "yaml") else {
            return nil
        }
        return FilePath(path)
    }
} 