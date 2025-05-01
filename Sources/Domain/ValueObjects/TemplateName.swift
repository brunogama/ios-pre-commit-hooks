import Foundation

/// A template identifier with validation
public final class TemplateName {
    private let value: String
    
    public init(_ name: String) {
        self.value = name.replacingOccurrences(of: ".yaml", with: "")
    }
    
    public var name: String {
        return value
    }
} 